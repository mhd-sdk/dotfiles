import qs
import qs.services
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import "./notifications"
import "./volumeMixer"
import "./wifiNetworks"
import "./bluetoothDevices"

Item {
    id: root
    property bool showWifiDialog: false
    property bool showBluetoothDialog: false

    readonly property int animDuration: 300

    Connections {
        target: GlobalState
        function onSidebarRightOpenChanged() {
            if (!GlobalState.sidebarRightOpen) {
                root.showWifiDialog = false
                root.showBluetoothDialog = false
            }
        }
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color: Theme.primary
        border.width: 1
        border.color: Theme.primary_container
        radius: 0
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            // ── Quick Toggles ──────────────────────────────────────────────
            Row {
                Layout.fillWidth: true
                spacing: 5

                // WiFi toggle
                Rectangle {
                    id: wifiToggle
                    width: 44
                    height: 44
                    radius: 0
                    color: wifiHover.hovered
                        ? Nmcli.wifiEnabled ? Qt.lighter(Theme.primary_container, 1.15) : Qt.rgba(0,0,0,0.22)
                        : Nmcli.wifiEnabled ? Theme.primary_container : Qt.rgba(0,0,0,0.1)
                    Behavior on color { ColorAnimation { duration: root.animDuration } }

                    Text {
                        anchors.centerIn: parent
                        text: Nmcli.wifiEnabled ? "󰤨" : "󰤭"
                        font.pixelSize: 16
                        font.family: Settings.iconFont
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: Nmcli.wifiEnabled ? Theme.on_primary_container : Theme.on_primary
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    HoverHandler { id: wifiHover }
                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onTapped: Nmcli.toggleWifi(null)
                    }
                    TapHandler {
                        acceptedButtons: Qt.RightButton
                        onTapped: {
                            Nmcli.rescanWifi()
                            root.showWifiDialog = true
                        }
                    }
                }

                // Bluetooth toggle
                Rectangle {
                    id: btToggle
                    width: 44
                    height: 44
                    radius: 0
                    property bool btEnabled: Bluetooth.defaultAdapter?.enabled ?? false
                    color: btHover.hovered
                        ? btEnabled ? Qt.lighter(Theme.primary_container, 1.15) : Qt.rgba(0,0,0,0.22)
                        : btEnabled ? Theme.primary_container : Qt.rgba(0,0,0,0.1)
                    Behavior on color { ColorAnimation { duration: root.animDuration } }

                    Text {
                        anchors.centerIn: parent
                        text: btToggle.btEnabled ? "󰂯" : "󰂲"
                        font.pixelSize: 16
                        font.family: Settings.iconFont
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: btToggle.btEnabled ? Theme.on_primary_container : Theme.on_primary
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    HoverHandler { id: btHover }
                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onTapped: {
                            if (Bluetooth.defaultAdapter)
                                Bluetooth.defaultAdapter.enabled = !(Bluetooth.defaultAdapter?.enabled ?? false)
                        }
                    }
                    TapHandler {
                        acceptedButtons: Qt.RightButton
                        onTapped: {
                            if (Bluetooth.defaultAdapter) {
                                Bluetooth.defaultAdapter.enabled = true
                                Bluetooth.defaultAdapter.discovering = true
                            }
                            root.showBluetoothDialog = true
                        }
                    }
                }

                // Scanning indicator
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Nmcli.scanning
                    text: "scanning..."
                    font.pixelSize: 16
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_primary
                }
            }

            // ── Center Widget (Notifications + Volume) ─────────────────────
            CenterWidgetGroup {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            // ── Bottom Widget (Calendar) ───────────────────────────────────
            BottomWidgetGroup {
                Layout.fillWidth: true
                Layout.fillHeight: false
            }
        }
    }

    // ── WiFi Dialog ────────────────────────────────────────────────────────
    onShowWifiDialogChanged: if (showWifiDialog) wifiLoader.active = true

    Loader {
        id: wifiLoader
        anchors.fill: parent
        z: 100
        active: root.showWifiDialog
        onActiveChanged: {
            if (active && item) {
                item.show = true
                item.forceActiveFocus()
            }
        }
        sourceComponent: WifiDialog {
            onDismiss: {
                show = false
                root.showWifiDialog = false
            }
        }
    }

    // ── Bluetooth Dialog ───────────────────────────────────────────────────
    onShowBluetoothDialogChanged: {
        if (showBluetoothDialog) btLoader.active = true
        else if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.discovering = false
    }

    Loader {
        id: btLoader
        anchors.fill: parent
        z: 100
        active: root.showBluetoothDialog
        onActiveChanged: {
            if (active && item) {
                item.show = true
                item.forceActiveFocus()
            }
        }
        sourceComponent: BluetoothDialog {
            onDismiss: {
                show = false
                root.showBluetoothDialog = false
            }
        }
    }
}
