import qs
import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

Item {
    id: root
    property bool show: false
    signal dismiss()

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) root.dismiss()
    }

    // ── Scrim ───────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: 0
        color: Qt.rgba(0, 0, 0, 0.5)
        opacity: root.show ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.dismiss()
        }
    }

    // ── Dialog panel ────────────────────────────────────────────────────────
    Rectangle {
        id: panel
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 20
        }
        radius: 0
        color: Theme.surface_container_high
        height: Math.min(parent.height * 0.75, btDialogContent.implicitHeight)

        opacity: root.show ? 1 : 0
        y: root.show
            ? parent.height / 2 - height / 2
            : parent.height / 2 - height / 2 + 24

        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: false
        }

        ColumnLayout {
            id: btDialogContent
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
            spacing: 0

            // Title
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 16
                Layout.bottomMargin: 8

                Text {
                    text: "Bluetooth"
                    font.pixelSize: 16
                    font.bold: true
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_surface_variant
                }

                Item { Layout.fillWidth: true }

                // Discovering indicator
                Text {
                    visible: Bluetooth.defaultAdapter?.discovering ?? false
                    text: "scanning..."
                    font.pixelSize: 16
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.outline
                }

                // Scan toggle button
                Rectangle {
                    width: 28
                    height: 28
                    radius: 0
                    color: scanHover.hovered ? Theme.surface_container_highest : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Text {
                        anchors.centerIn: parent
                        text: "󰑓"
                        font.pixelSize: 16
                        font.family: Settings.iconFont
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: Theme.on_surface_variant
                    }
                    HoverHandler { id: scanHover }
                    TapHandler {
                        onTapped: {
                            if (Bluetooth.defaultAdapter) {
                                Bluetooth.defaultAdapter.discovering = !Bluetooth.defaultAdapter.discovering
                            }
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.outline_variant }

            // Device list
            ListView {
                id: deviceList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 0

                model: [...(Bluetooth.devices.values ?? [])].sort((a, b) => {
                    const conn = (b.connected ? 1 : 0) - (a.connected ? 1 : 0)
                        || (b.paired ? 1 : 0) - (a.paired ? 1 : 0)
                    if (conn !== 0) return conn
                    return (a.name ?? "").localeCompare(b.name ?? "")
                })

                delegate: BluetoothDeviceItem {
                    required property var modelData
                    device: modelData
                    width: deviceList.width
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.outline_variant }

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 12

                Item { Layout.fillWidth: true }

                Rectangle {
                    height: 30
                    width: btDoneTxt.implicitWidth + 24
                    radius: 0
                    color: btDoneHover.hovered ? Qt.lighter(Theme.primary, 1.15) : Theme.primary
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Text {
                        id: btDoneTxt
                        anchors.centerIn: parent
                        text: "Done"
                        font.pixelSize: 16
                        font.family: Settings.font
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: Theme.on_primary
                    }
                    HoverHandler { id: btDoneHover }
                    TapHandler { onTapped: root.dismiss() }
                }
            }
        }
    }
}
