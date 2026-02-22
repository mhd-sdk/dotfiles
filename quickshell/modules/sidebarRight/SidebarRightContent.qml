import qs
import qs.services
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import "./notifications"
import "./volumeMixer"
import "./wifiNetworks"
import "./bluetoothDevices"



Item {
    id: root
    property string screenName: ""
    property bool showWifiDialog: false
    property bool showBluetoothDialog: false

    readonly property int animDuration: 300

    ScreenBrightness {
        id: brightness
        screenName: root.screenName
    }


    Connections {
        target: GlobalState
        function onSidebarRightOpenChanged() {
            if (!GlobalState.sidebarRightOpen) {
                root.showWifiDialog = false;
                root.showBluetoothDialog = false;
            }
        }
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color: Theme.background
        //border.width: 1
        //border.color: Theme.outline_variant
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
                    color: wifiHover.hovered ? Nmcli.wifiEnabled ? Qt.lighter(Theme.primary, 1.1) : Theme.surface_container_high : Nmcli.wifiEnabled ? Theme.primary : Theme.surface_container
                    Behavior on color {
                        ColorAnimation {
                            duration: root.animDuration
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: Nmcli.wifiEnabled ? "󰤨" : "󰤭"
                        font.pixelSize: 16
                        font.family: Settings.iconFont
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: Nmcli.wifiEnabled ? Theme.on_primary : Theme.on_surface
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    HoverHandler {
                        id: wifiHover
                    }
                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onTapped: Nmcli.toggleWifi(null)
                    }
                    TapHandler {
                        acceptedButtons: Qt.RightButton
                        onTapped: {
                            Nmcli.rescanWifi();
                            root.showWifiDialog = true;
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
                    color: btHover.hovered ? btEnabled ? Qt.lighter(Theme.primary, 1.1) : Theme.surface_container_high : btEnabled ? Theme.primary : Theme.surface_container
                    Behavior on color {
                        ColorAnimation {
                            duration: root.animDuration
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: btToggle.btEnabled ? "󰂯" : "󰂲"
                        font.pixelSize: 16
                        font.family: Settings.iconFont
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: btToggle.btEnabled ? Theme.on_primary : Theme.on_surface
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    HoverHandler {
                        id: btHover
                    }
                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onTapped: {
                            if (Bluetooth.defaultAdapter)
                                Bluetooth.defaultAdapter.enabled = !(Bluetooth.defaultAdapter?.enabled ?? false);
                        }
                    }
                    TapHandler {
                        acceptedButtons: Qt.RightButton
                        onTapped: {
                            if (Bluetooth.defaultAdapter) {
                                Bluetooth.defaultAdapter.enabled = true;
                                Bluetooth.defaultAdapter.discovering = true;
                            }
                            root.showBluetoothDialog = true;
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
                    color: Theme.on_surface
                }
            }

            // ── Brightness slider ──────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: brightness.initialized

                Text {
                    text: brightness.value < 0.35 ? "󰃞" : brightness.value < 0.7 ? "󰃝" : "󰃠"
                    font.pixelSize: 16
                    font.family: Settings.iconFont
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_surface
                }

                Item {
                    Layout.fillWidth: true
                    height: 18

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 4
                        color: Theme.outline_variant
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: brightness.value * parent.width
                        height: 4
                        color: Theme.primary
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        x: brightness.value * (parent.width - width)
                        width: 12
                        height: 12
                        color: Theme.primary
                        Behavior on x {
                            enabled: !brightnessArea.pressed
                            NumberAnimation { duration: 100 }
                        }
                    }

                    MouseArea {
                        id: brightnessArea
                        anchors.fill: parent
                        onPositionChanged: mouse => {
                            if (pressed)
                                brightness.set(Math.max(0, Math.min(1, mouse.x / width)))
                        }
                        onClicked: mouse => {
                            brightness.set(Math.max(0, Math.min(1, mouse.x / width)))
                        }
                        onWheel: wheel => {
                            brightness.set(Math.max(0, Math.min(1, brightness.value + wheel.angleDelta.y / 1200)))
                        }
                    }
                }

                Text {
                    text: Math.round(brightness.value * 100) + "%"
                    font.pixelSize: 16
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_surface
                    Layout.minimumWidth: 32
                    horizontalAlignment: Text.AlignRight
                }
            }


            // ── Volume slider ──────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: VolumeService.muted ? "󰝟"
                        : volTrack.vol < 0.35 ? "󰕿"
                        : volTrack.vol < 0.7 ? "󰖀" : "󰕾"
                    font.pixelSize: 16
                    font.family: Settings.iconFont
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_surface
                }

                Item {
                    id: volTrack
                    Layout.fillWidth: true
                    height: 18
                    readonly property real vol: VolumeService.volume

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 4
                        color: Theme.outline_variant
                    }
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: volTrack.vol * parent.width
                        height: 4
                        color: Theme.primary
                    }
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        x: volTrack.vol * (parent.width - width)
                        width: 12
                        height: 12
                        color: Theme.primary
                        Behavior on x {
                            enabled: !volArea.pressed
                            NumberAnimation { duration: 100 }
                        }
                    }

                    MouseArea {
                        id: volArea
                        anchors.fill: parent
                        onPositionChanged: mouse => {
                            if (pressed)
                                VolumeService.set(mouse.x / width)
                        }
                        onClicked: mouse => {
                            VolumeService.set(mouse.x / width)
                        }
                        onWheel: wheel => {
                            VolumeService.set(volTrack.vol + wheel.angleDelta.y / 1200)
                        }
                    }
                }

                Text {
                    text: VolumeService.muted ? "muted"
                        : Math.round(volTrack.vol * 100) + "%"
                    font.pixelSize: 16
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_surface
                    Layout.minimumWidth: 40
                    horizontalAlignment: Text.AlignRight
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
    onShowWifiDialogChanged: if (showWifiDialog)
        wifiLoader.active = true

    Loader {
        id: wifiLoader
        anchors.fill: parent
        z: 100
        active: root.showWifiDialog
        onActiveChanged: {
            if (active && item) {
                item.show = true;
                item.forceActiveFocus();
            }
        }
        sourceComponent: WifiDialog {
            onDismiss: {
                show = false;
                root.showWifiDialog = false;
            }
        }
    }

    // ── Bluetooth Dialog ───────────────────────────────────────────────────
    onShowBluetoothDialogChanged: {
        if (showBluetoothDialog)
            btLoader.active = true;
        else if (Bluetooth.defaultAdapter)
            Bluetooth.defaultAdapter.discovering = false;
    }

    Loader {
        id: btLoader
        anchors.fill: parent
        z: 100
        active: root.showBluetoothDialog
        onActiveChanged: {
            if (active && item) {
                item.show = true;
                item.forceActiveFocus();
            }
        }
        sourceComponent: BluetoothDialog {
            onDismiss: {
                show = false;
                root.showBluetoothDialog = false;
            }
        }
    }
}
