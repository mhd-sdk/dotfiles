import qs
import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

Item {
    id: root
    required property var device
    property bool expanded: false

    height: itemContent.implicitHeight + 16
    Behavior on height {
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.fill: parent
        color: itemHover.hovered && !root.expanded
            ? Theme.surface_container_highest : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    ColumnLayout {
        id: itemContent
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 16
            rightMargin: 16
        }
        spacing: 6

        // ── Device row ─────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Bluetooth device icon (use generic icon)
            Text {
                text: root.device?.connected ? "󰂱" : "󰂯"
                font.pixelSize: 16
                font.family: Settings.iconFont
                renderType: Text.NativeRendering
                antialiasing: false
                font.hintingPreference: Font.PreferFullHinting
                color: root.device?.connected ? Theme.primary : Theme.on_surface_variant
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            // Name + status
            Column {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    width: parent.width
                    text: root.device?.name ?? "Unknown device"
                    font.pixelSize: 16
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_surface_variant
                    elide: Text.ElideRight
                }

                Text {
                    visible: (root.device?.connected ?? false) || (root.device?.paired ?? false)
                    width: parent.width
                    text: {
                        if (!(root.device?.paired ?? false)) return ""
                        let s = root.device?.connected ? "Connected" : "Paired"
                        if (root.device?.batteryAvailable ?? false)
                            s += " • " + Math.round((root.device?.battery ?? 0) * 100) + "%"
                        return s
                    }
                    font.pixelSize: 16
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.outline
                    elide: Text.ElideRight
                }
            }

            // Expand arrow
            Text {
                text: "󰅀"
                font.pixelSize: 16
                font.family: Settings.iconFont
                renderType: Text.NativeRendering
                antialiasing: false
                font.hintingPreference: Font.PreferFullHinting
                color: Theme.outline
                rotation: root.expanded ? 180 : 0
                Behavior on rotation {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
            }
        }

        // ── Action buttons (expanded) ──────────────────────────────────────
        Row {
            Layout.fillWidth: true
            visible: root.expanded
            opacity: root.expanded ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
            spacing: 8
            layoutDirection: Qt.RightToLeft

            // Connect/Disconnect
            Rectangle {
                height: 28
                width: connectTxt.implicitWidth + 20
                radius: 0
                color: connectHover.hovered ? Qt.lighter(Theme.primary, 1.15) : Theme.primary
                Behavior on color { ColorAnimation { duration: 120 } }
                Text {
                    id: connectTxt
                    anchors.centerIn: parent
                    text: root.device?.connected ? "Disconnect" : "Connect"
                    font.pixelSize: 16
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_primary
                }
                HoverHandler { id: connectHover }
                TapHandler {
                    onTapped: {
                        if (root.device?.connected)
                            root.device.disconnect()
                        else
                            root.device.connect()
                    }
                }
            }

            // Forget (only when paired)
            Rectangle {
                visible: root.device?.paired ?? false
                height: 28
                width: forgetTxt.implicitWidth + 20
                radius: 0
                color: forgetHover.hovered ? Qt.lighter(Theme.error, 1.15) : Theme.error
                Behavior on color { ColorAnimation { duration: 120 } }
                Text {
                    id: forgetTxt
                    anchors.centerIn: parent
                    text: "Forget"
                    font.pixelSize: 16
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_error
                }
                HoverHandler { id: forgetHover }
                TapHandler {
                    onTapped: root.device?.forget()
                }
            }
        }
    }

    TapHandler {
        onTapped: root.expanded = !root.expanded
    }

    HoverHandler { id: itemHover }
}
