import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Item {
    id: root

    property string screenName: ""
    property real value: 0
    property bool initialized: false
    property int bus: -1

    Component.onCompleted: _resolve()

    function _resolve() {
        if (BrightnessService.ready)
            _pickBus()
        // else: onReadyChanged below handles it
    }

    function _pickBus() {
        const map = BrightnessService.busMap
        let b = (screenName !== "") ? (map[screenName] ?? -1) : -1
        if (b < 0) {
            const keys = Object.keys(map)
            if (keys.length > 0) b = map[keys[0]]
        }
        if (b >= 0) bus = b
    }

    // Try to init from the pre-fetched cache. Returns true if successful.
    function _loadFromCache() {
        if (bus < 0) return false
        const cached = BrightnessService.brightnessCache[bus]
        if (cached !== undefined) {
            value = cached
            initialized = true
            return true
        }
        return false
    }

    onScreenNameChanged: {
        initialized = false
        bus = -1
        _resolve()
    }

    onBusChanged: {
        if (bus < 0) return
        // Try cache first (instant), fall back to getvcp
        if (!_loadFromCache())
            getProc.running = true
    }

    Connections {
        target: BrightnessService
        function onReadyChanged() {
            if (BrightnessService.ready && !root.initialized)
                root._pickBus()
        }
        // Cache gets populated after detect+getvcp at startup — pick it up if not yet initialized
        function onBrightnessCacheChanged() {
            if (root.bus >= 0 && !root.initialized)
                root._loadFromCache()
        }
    }

    function set(v) {
        if (!initialized || bus < 0) return
        root.value = Math.max(0, Math.min(1, v))
        BrightnessService.updateCache(bus, root.value)
        setProc.command = ["ddcutil", "--bus", bus.toString(), "setvcp", "10",
                           Math.round(root.value * 100).toString()]
        setProc.running = true
    }

    Process {
        id: getProc
        command: ["ddcutil", "--bus", root.bus.toString(), "getvcp", "10", "--terse"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/)
                if (parts.length >= 5) {
                    const cur = parseInt(parts[3])
                    const max = parseInt(parts[4])
                    if (!isNaN(cur) && !isNaN(max) && max > 0) {
                        root.value = cur / max
                        BrightnessService.updateCache(root.bus, root.value)
                        root.initialized = true
                    }
                }
            }
        }
    }

    Process { id: setProc }
}
