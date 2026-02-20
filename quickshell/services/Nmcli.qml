pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool wifiEnabled: true
    readonly property bool scanning: rescanProc.running
    readonly property list<AccessPoint> networks: []
    readonly property AccessPoint active: networks.find(n => n.active) ?? null
    property list<string> savedConnections: []
    property list<string> savedConnectionSsids: []

    property var pendingConnection: null
    signal connectionFailed(string ssid)

    readonly property string connectionTypeWireless: "802-11-wireless"

    function detectPasswordRequired(error: string): bool {
        if (!error || error.length === 0) {
            return false
        }

        return (error.includes("Secrets were required") ||
                error.includes("No secrets provided") ||
                error.includes("802-11-wireless-security.psk") ||
                error.includes("password for") ||
                (error.includes("password") && !error.includes("Connection activated") && !error.includes("successfully"))) &&
                !error.includes("Connection activated") &&
                !error.includes("successfully")
    }

    function parseNetworkOutput(output: string): list<var> {
        if (!output || output.length === 0) {
            return []
        }

        const PLACEHOLDER = "\x01"
        const allNetworks = output.trim().split("\n").filter(line => line && line.length > 0).map(n => {
            const net = n.replace(/\\:/g, PLACEHOLDER).split(":")
            return {
                active: net[0] === "yes",
                strength: parseInt(net[1] || "0", 10) || 0,
                frequency: parseInt(net[2] || "0", 10) || 0,
                ssid: (net[3]?.replace(new RegExp(PLACEHOLDER, "g"), ":") ?? "").trim(),
                bssid: (net[4]?.replace(new RegExp(PLACEHOLDER, "g"), ":") ?? "").trim(),
                security: (net[5] ?? "").trim()
            }
        }).filter(n => n.ssid && n.ssid.length > 0)

        return allNetworks
    }

    function deduplicateNetworks(networks: list<var>): list<var> {
        if (!networks || networks.length === 0) {
            return []
        }

        const networkMap = new Map()
        for (const network of networks) {
            const existing = networkMap.get(network.ssid)
            if (!existing) {
                networkMap.set(network.ssid, network)
            } else {
                if (network.active && !existing.active) {
                    networkMap.set(network.ssid, network)
                } else if (!network.active && !existing.active) {
                    if (network.strength > existing.strength) {
                        networkMap.set(network.ssid, network)
                    }
                }
            }
        }

        return Array.from(networkMap.values())
    }

    function connectToNetworkWithPasswordCheck(ssid: string, isSecure: bool, callback: var, bssid: string): void {
        if (isSecure) {
            connectWireless(ssid, "", bssid, result => {
                if (result.success) {
                    if (callback) callback({
                        success: true,
                        usedSavedPassword: true,
                        output: result.output,
                        error: "",
                        exitCode: 0
                    })
                } else if (result.needsPassword) {
                    if (callback) callback({
                        success: false,
                        needsPassword: true,
                        output: result.output,
                        error: result.error,
                        exitCode: result.exitCode
                    })
                } else {
                    if (callback) callback(result)
                }
            })
        } else {
            connectWireless(ssid, "", bssid, callback)
        }
    }

    function connectToNetwork(ssid: string, password: string, bssid: string, callback: var): void {
        connectWireless(ssid, password, bssid, callback)
    }

    function connectWireless(ssid: string, password: string, bssid: string, callback: var, retryCount: int): void {
        const hasBssid = bssid !== undefined && bssid !== null && bssid.length > 0
        const retries = retryCount !== undefined ? retryCount : 0
        const maxRetries = 2

        if (callback) {
            root.pendingConnection = {
                ssid: ssid,
                bssid: hasBssid ? bssid : "",
                callback: callback,
                retryCount: retries
            }
            connectionCheckTimer.start()
            immediateCheckTimer.checkCount = 0
            immediateCheckTimer.start()
        }

        if (password && password.length > 0 && hasBssid) {
            const bssidUpper = bssid.toUpperCase()
            createConnectionWithPassword(ssid, bssidUpper, password, callback)
            return
        }

        let cmd = ["nmcli", "device", "wifi", "connect", ssid]
        if (password && password.length > 0) {
            cmd.push("password", password)
        }

        const proc = connectProc.createObject(root)
        proc.command = cmd
        proc.callback = callback
        proc.running = true
    }

    function createConnectionWithPassword(ssid: string, bssidUpper: string, password: string, callback: var): void {
        checkAndDeleteConnection(ssid, () => {
            const cmd = ["nmcli", "connection", "add", "type", "wifi", "con-name", ssid,
                         "ifname", "*", "ssid", ssid, "802-11-wireless.bssid", bssidUpper,
                         "802-11-wireless-security.key-mgmt", "wpa-psk",
                         "802-11-wireless-security.psk", password]

            const proc = addConnProc.createObject(root)
            proc.command = cmd
            proc.ssid = ssid
            proc.callback = callback
            proc.running = true
        })
    }

    function checkAndDeleteConnection(ssid: string, callback: var): void {
        const proc = checkConnProc.createObject(root)
        proc.command = ["nmcli", "connection", "show", ssid]
        proc.ssid = ssid
        proc.callback = callback
        proc.running = true
    }

    function activateConnection(connectionName: string, callback: var): void {
        const proc = upConnProc.createObject(root)
        proc.command = ["nmcli", "connection", "up", connectionName]
        proc.callback = callback
        proc.running = true
    }

    function hasSavedProfile(ssid: string): bool {
        if (!ssid || ssid.length === 0) {
            return false
        }
        const ssidLower = ssid.toLowerCase().trim()

        if (root.active && root.active.ssid) {
            const activeSsidLower = root.active.ssid.toLowerCase().trim()
            if (activeSsidLower === ssidLower) {
                return true
            }
        }

        const hasSsid = root.savedConnectionSsids.some(savedSsid =>
            savedSsid && savedSsid.toLowerCase().trim() === ssidLower)

        if (hasSsid) {
            return true
        }

        const hasConnectionName = root.savedConnections.some(connName =>
            connName && connName.toLowerCase().trim() === ssidLower)

        return hasConnectionName
    }

    function forgetNetwork(ssid: string, callback: var): void {
        if (!ssid || ssid.length === 0) {
            if (callback) callback({
                success: false,
                output: "",
                error: "No SSID specified",
                exitCode: -1
            })
            return
        }

        const connectionName = root.savedConnections.find(conn =>
            conn && conn.toLowerCase().trim() === ssid.toLowerCase().trim()) || ssid

        const proc = deleteConnProc.createObject(root)
        proc.command = ["nmcli", "connection", "delete", connectionName]
        proc.callback = callback
        proc.running = true
    }

    function disconnectFromNetwork(): void {
        if (active && active.ssid) {
            const proc = disconnectProc.createObject(root)
            proc.command = ["nmcli", "connection", "down", active.ssid]
            proc.running = true
        } else {
            const proc = disconnectProc.createObject(root)
            proc.command = ["nmcli", "device", "disconnect", "wifi"]
            proc.running = true
        }
    }

    function rescanWifi(): void {
        rescanProc.running = true
    }

    function enableWifi(enabled: bool, callback: var): void {
        const cmd = enabled ? "on" : "off"
        const proc = toggleWifiProc.createObject(root)
        proc.command = ["nmcli", "radio", "wifi", cmd]
        proc.callback = callback
        proc.running = true
    }

    function toggleWifi(callback: var): void {
        enableWifi(!root.wifiEnabled, callback)
    }

    function getNetworks(callback: var): void {
        const proc = listNetworksProc.createObject(root)
        proc.callback = callback
        proc.running = true
    }

    function loadSavedConnections(callback: var): void {
        const proc = listConnectionsProc.createObject(root)
        proc.callback = callback
        proc.running = true
    }

    function checkPendingConnection(): void {
        if (root.pendingConnection) {
            Qt.callLater(() => {
                const connected = root.active && root.active.ssid === root.pendingConnection.ssid
                if (connected) {
                    connectionCheckTimer.stop()
                    immediateCheckTimer.stop()
                    immediateCheckTimer.checkCount = 0
                    if (root.pendingConnection.callback) {
                        root.pendingConnection.callback({
                            success: true,
                            output: "Connected",
                            error: "",
                            exitCode: 0
                        })
                    }
                    root.pendingConnection = null
                } else {
                    if (!immediateCheckTimer.running) {
                        immediateCheckTimer.start()
                    }
                }
            })
        }
    }

    // ── Process Components ────────────────────────────────────────────────────

    component ConnectProcess: Process {
        id: proc
        property var callback: null
        property bool callbackCalled: false

        stdout: StdioCollector { id: stdoutColl }
        stderr: StdioCollector { id: stderrColl }

        onExited: code => {
            Qt.callLater(() => {
                if (callbackCalled) return

                const output = stdoutColl.text
                const error = stderrColl.text
                const success = code === 0
                const needsPassword = root.detectPasswordRequired(error)

                if (needsPassword && root.pendingConnection && callback) {
                    connectionCheckTimer.stop()
                    immediateCheckTimer.stop()
                    immediateCheckTimer.checkCount = 0
                    const pending = root.pendingConnection
                    root.pendingConnection = null
                    callbackCalled = true
                    callback({
                        success: false,
                        output: output,
                        error: error,
                        exitCode: code,
                        needsPassword: true
                    })
                } else if (!success && root.pendingConnection) {
                    root.connectionFailed(root.pendingConnection.ssid)
                }

                proc.destroy()
            })
        }
    }

    Component { id: connectProc; ConnectProcess {} }

    component AddConnectionProcess: Process {
        property var callback: null
        property string ssid: ""

        stdout: StdioCollector {}
        stderr: StdioCollector { id: addStderr }

        onExited: code => {
            if (code === 0) {
                loadSavedConnections(() => {})
                activateConnection(ssid, callback)
            } else {
                const error = addStderr.text
                const hasDuplicateWarning = error && (error.includes("another connection with the name") ||
                                                      error.includes("Reference the connection by its uuid"))
                if (hasDuplicateWarning || (code > 0 && code < 10)) {
                    loadSavedConnections(() => {})
                    activateConnection(ssid, callback)
                } else {
                    // Fallback
                    const proc = connectProc.createObject(root)
                    proc.command = ["nmcli", "device", "wifi", "connect", ssid, "password", "***"]
                    proc.callback = callback
                    proc.running = true
                }
            }
            destroy()
        }
    }

    Component { id: addConnProc; AddConnectionProcess {} }

    component CheckConnectionProcess: Process {
        property var callback: null
        property string ssid: ""

        stdout: StdioCollector {}
        stderr: StdioCollector {}

        onExited: code => {
            if (code === 0) {
                // Connection exists, delete it
                const proc = deleteConnProc.createObject(root)
                proc.command = ["nmcli", "connection", "delete", ssid]
                proc.onExited.connect(() => {
                    Qt.callLater(() => { if (callback) callback() }, 300)
                })
                proc.running = true
            } else {
                if (callback) callback()
            }
            destroy()
        }
    }

    Component { id: checkConnProc; CheckConnectionProcess {} }

    component UpConnectionProcess: Process {
        property var callback: null

        stdout: StdioCollector {}
        stderr: StdioCollector {}

        onExited: code => {
            if (callback) callback({ success: code === 0 })
            destroy()
        }
    }

    Component { id: upConnProc; UpConnectionProcess {} }

    component DeleteConnectionProcess: Process {
        property var callback: null

        stdout: StdioCollector {}
        stderr: StdioCollector {}

        onExited: code => {
            if (code === 0) {
                Qt.callLater(() => { loadSavedConnections(() => {}) }, 500)
            }
            if (callback) callback({ success: code === 0 })
            destroy()
        }
    }

    Component { id: deleteConnProc; DeleteConnectionProcess {} }

    component DisconnectProcess: Process {
        stdout: StdioCollector {}
        stderr: StdioCollector {}

        onExited: () => {
            getNetworks(() => {})
            destroy()
        }
    }

    Component { id: disconnectProc; DisconnectProcess {} }

    component ToggleWifiProcess: Process {
        property var callback: null

        stdout: StdioCollector {}
        stderr: StdioCollector {}

        onExited: code => {
            if (code === 0) {
                getWifiStatusProc.running = true
            }
            if (callback) callback({ success: code === 0 })
            destroy()
        }
    }

    Component { id: toggleWifiProc; ToggleWifiProcess {} }

    component ListNetworksProcess: Process {
        property var callback: null

        command: ["nmcli", "-g", "ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY", "d", "w"]
        stdout: StdioCollector {
            onStreamFinished: {
                const allNetworks = parseNetworkOutput(text)
                const networks = deduplicateNetworks(allNetworks)
                const rNetworks = root.networks

                const destroyed = rNetworks.filter(rn =>
                    !networks.find(n => n.frequency === rn.frequency && n.ssid === rn.ssid && n.bssid === rn.bssid))
                for (const network of destroyed) {
                    const index = rNetworks.indexOf(network)
                    if (index >= 0) {
                        rNetworks.splice(index, 1)
                        network.destroy()
                    }
                }

                for (const network of networks) {
                    const match = rNetworks.find(n =>
                        n.frequency === network.frequency && n.ssid === network.ssid && n.bssid === network.bssid)
                    if (match) {
                        match.lastIpcObject = network
                    } else {
                        rNetworks.push(apComp.createObject(root, { lastIpcObject: network }))
                    }
                }

                if (callback) callback(root.networks)
                checkPendingConnection()
            }
        }

        onExited: () => { destroy() }
    }

    Component { id: listNetworksProc; ListNetworksProcess {} }

    component ListConnectionsProcess: Process {
        property var callback: null

        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n").filter(line => line.length > 0)
                const wifiConnections = []
                const connections = []

                for (const line of lines) {
                    const parts = line.split(":")
                    if (parts.length >= 2) {
                        const name = parts[0]
                        const type = parts[1]
                        connections.push(name)

                        if (type === root.connectionTypeWireless) {
                            wifiConnections.push(name)
                        }
                    }
                }

                root.savedConnections = connections

                if (wifiConnections.length > 0) {
                    root.savedConnectionSsids = []
                    querySsids(wifiConnections, 0, callback)
                } else {
                    root.savedConnectionSsids = []
                    if (callback) callback(root.savedConnectionSsids)
                }
            }
        }

        onExited: () => { destroy() }
    }

    Component { id: listConnectionsProc; ListConnectionsProcess {} }

    function querySsids(connections: list<string>, index: int, callback: var): void {
        if (index < connections.length) {
            const connectionName = connections[index]
            const proc = querySsidProc.createObject(root)
            proc.command = ["nmcli", "-t", "-f", "802-11-wireless.ssid", "connection", "show", connectionName]
            proc.index = index
            proc.connections = connections
            proc.finalCallback = callback
            proc.running = true
        } else {
            if (callback) callback(root.savedConnectionSsids)
        }
    }

    component QuerySsidProcess: Process {
        property var finalCallback: null
        property list<string> connections: []
        property int index: 0

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                for (const line of lines) {
                    if (line.startsWith("802-11-wireless.ssid:")) {
                        const ssid = line.substring("802-11-wireless.ssid:".length).trim()
                        if (ssid && ssid.length > 0) {
                            const ssidLower = ssid.toLowerCase()
                            const exists = root.savedConnectionSsids.some(s =>
                                s && s.toLowerCase() === ssidLower)
                            if (!exists) {
                                const newList = root.savedConnectionSsids.slice()
                                newList.push(ssid)
                                root.savedConnectionSsids = newList
                            }
                        }
                    }
                }
            }
        }

        onExited: () => {
            querySsids(connections, index + 1, finalCallback)
            destroy()
        }
    }

    Component { id: querySsidProc; QuerySsidProcess {} }

    // ── Timers ────────────────────────────────────────────────────────────────

    Timer {
        id: connectionCheckTimer
        interval: 4000
        onTriggered: {
            if (root.pendingConnection) {
                const connected = root.active && root.active.ssid === root.pendingConnection.ssid

                if (!connected && root.pendingConnection.callback) {
                    const pending = root.pendingConnection
                    root.pendingConnection = null
                    immediateCheckTimer.stop()
                    immediateCheckTimer.checkCount = 0
                    root.connectionFailed(pending.ssid)
                    pending.callback({
                        success: false,
                        output: "",
                        error: "Connection timeout",
                        exitCode: -1,
                        needsPassword: false
                    })
                } else if (connected) {
                    root.pendingConnection = null
                    immediateCheckTimer.stop()
                    immediateCheckTimer.checkCount = 0
                }
            }
        }
    }

    Timer {
        id: immediateCheckTimer
        property int checkCount: 0
        interval: 500
        repeat: true
        triggeredOnStart: false

        onTriggered: {
            if (root.pendingConnection) {
                checkCount++
                const connected = root.active && root.active.ssid === root.pendingConnection.ssid

                if (connected) {
                    connectionCheckTimer.stop()
                    immediateCheckTimer.stop()
                    immediateCheckTimer.checkCount = 0
                    if (root.pendingConnection.callback) {
                        root.pendingConnection.callback({
                            success: true,
                            output: "Connected",
                            error: "",
                            exitCode: 0
                        })
                    }
                    root.pendingConnection = null
                } else if (checkCount >= 6) {
                    immediateCheckTimer.stop()
                    immediateCheckTimer.checkCount = 0
                }
            } else {
                immediateCheckTimer.stop()
                immediateCheckTimer.checkCount = 0
            }
        }
    }

    // ── Background Processes ──────────────────────────────────────────────────

    Process {
        id: rescanProc
        command: ["nmcli", "dev", "wifi", "list", "--rescan", "yes"]
        stdout: StdioCollector {}
        onExited: root.getNetworks(() => {})
    }

    Process {
        id: getWifiStatusProc
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = text.trim() === "enabled"
            }
        }
    }

    Process {
        id: monitorProc
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: refreshOnConnectionChange()
        }
        onExited: monitorRestartTimer.start()
    }

    Timer {
        id: monitorRestartTimer
        interval: 2000
        onTriggered: monitorProc.running = true
    }

    function refreshOnConnectionChange(): void {
        getNetworks(() => {})
    }

    // ── AccessPoint Component ─────────────────────────────────────────────────

    component AccessPoint: QtObject {
        required property var lastIpcObject
        readonly property string ssid: lastIpcObject.ssid
        readonly property string bssid: lastIpcObject.bssid
        readonly property int strength: lastIpcObject.strength
        readonly property int frequency: lastIpcObject.frequency
        readonly property bool active: lastIpcObject.active
        readonly property string security: lastIpcObject.security
        readonly property bool isSecure: security.length > 0
    }

    Component { id: apComp; AccessPoint {} }

    // ── Initialization ────────────────────────────────────────────────────────

    Component.onCompleted: {
        getWifiStatusProc.running = true
        getNetworks(() => {})
        loadSavedConnections(() => {})
    }
}
