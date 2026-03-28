import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Bluetooth
import qs
import qs.services

Item {
    id: root
    property string screenName: ""

    height: parent.height
    anchors.right: parent.right
    implicitWidth: row.implicitWidth + 12

    // ── Keyboard layout ───────────────────────────────────────────────────────
    property string keyboardLayout: ""

    function parseLayout(fullName) {
        return fullName.split(/[\s(,]/)[0].slice(0, 2).toUpperCase()
    }

    Process {
        id: devicesProc
        command: ["hyprctl", "-j", "devices"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const devices = JSON.parse(text)
                    const kb = devices.keyboards.find(k => k.main) ?? devices.keyboards[0]
                    if (kb) root.keyboardLayout = root.parseLayout(kb.active_keymap)
                } catch (e) {}
            }
        }
        Component.onCompleted: running = true
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activelayout") devicesProc.running = true
        }
    }

    // ── Ethernet ──────────────────────────────────────────────────────────────
    property bool ethernetConnected: false

    Process {
        id: ethernetProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE", "device"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.ethernetConnected = text.split("\n").some(
                    line => line.startsWith("ethernet:connected"))
            }
        }
        Component.onCompleted: running = true
    }

    Connections {
        target: Nmcli
        function onActiveChanged() { ethernetProc.running = true }
    }

    // ── Network icon helper ───────────────────────────────────────────────────
    function networkIcon(): string {
        if (root.ethernetConnected) return "󰈀"
        if (!Nmcli.wifiEnabled) return "󰤭"
        const ap = Nmcli.active
        if (!ap) return "󰤫"
        const s = ap.strength
        if (s >= 76) return "󰤨"
        if (s >= 51) return "󰤥"
        if (s >= 26) return "󰤢"
        return "󰤟"
    }

    function networkActive(): bool {
        return root.ethernetConnected || Nmcli.active !== null
    }

    // ── Bluetooth icon helper ─────────────────────────────────────────────────
    function btIcon(): string {
        if (!Bluetooth.defaultAdapter || !Bluetooth.defaultAdapter.enabled) return "󰂲"
        const devs = Bluetooth.devices
        for (const k in devs) {
            if (devs[k].connected) return "󰂯"
        }
        return "󰂱"
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 6
        spacing: 0

        // Keyboard layout
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.keyboardLayout
            font.pixelSize: 16
            font.family: Settings.font
            renderType: Text.NativeRendering
            antialiasing: false
            font.hintingPreference: Font.PreferFullHinting
            color: Theme.on_surface_variant
            rightPadding: 12
            visible: root.keyboardLayout.length > 0
            font.capitalization: Font.AllUppercase
        }

        // Menu button (WiFi + BT + menu icon)
        Rectangle {
            id: menuBtn
            height: root.height
            implicitWidth: iconsRow.implicitWidth + 16
            radius: 0
            color: GlobalState.sidebarRightOpen ? Theme.primary
                : menuHover.hovered ? Theme.surface_container_high
                : "transparent"
            Behavior on color { ColorAnimation { duration: 120 } }

            Row {
                id: iconsRow
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 8
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.networkIcon()
                    font.pixelSize: 16
                    font.family: Settings.iconFont
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: GlobalState.sidebarRightOpen ? Theme.on_primary
                        : root.networkActive() ? Theme.on_surface : Theme.on_surface_variant
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.btIcon()
                    font.pixelSize: 16
                    font.family: Settings.iconFont
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: GlobalState.sidebarRightOpen ? Theme.on_primary
                        : (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled)
                            ? Theme.on_surface : Theme.on_surface_variant
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰍜"
                    font.pixelSize: 16
                    font.family: Settings.iconFont
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: GlobalState.sidebarRightOpen ? Theme.on_primary : Theme.on_surface_variant
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
            }

            HoverHandler { id: menuHover }

            TapHandler {
                onTapped: {
                    GlobalState.sidebarRightScreen = root.screenName
                    GlobalState.sidebarRightOpen = !GlobalState.sidebarRightOpen
                }
            }
        }
    }
}
