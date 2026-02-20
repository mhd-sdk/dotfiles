import qs
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

Item {
    id: root

    // ── Notification list ──────────────────────────────────────────────────
    ListView {
        id: listView
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: statusRow.top
            bottomMargin: 4
        }
        clip: true
        model: Notifications.list
        spacing: 4

        delegate: NotificationItem {
            required property var modelData
            notification: modelData
            anchors.left: parent?.left
            anchors.right: parent?.right
            anchors.leftMargin: 8
            anchors.rightMargin: 8
        }
    }

    // ── Empty placeholder ──────────────────────────────────────────────────
    Item {
        anchors.fill: listView
        visible: opacity > 0
        opacity: Notifications.list.length === 0 ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 350; easing.type: Easing.OutExpo }
        }

        Column {
            anchors.centerIn: parent
            spacing: 6

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "󱅫"
                font.pixelSize: 48
                font.family: Settings.iconFont
                renderType: Text.NativeRendering
                antialiasing: false
                font.hintingPreference: Font.PreferFullHinting
                color: Theme.on_primary_container
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "No notifications"
                font.pixelSize: 16
                font.family: Settings.iconFont
                renderType: Text.NativeRendering
                antialiasing: false
                font.hintingPreference: Font.PreferFullHinting
                color: Theme.on_primary_container
            }
        }
    }

    // ── Status row ─────────────────────────────────────────────────────────
    Item {
        id: statusRow
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 34

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
            text: Notifications.list.length + " notification" +
                  (Notifications.list.length !== 1 ? "s" : "")
            font.pixelSize: 16
            font.family: Settings.font
            renderType: Text.NativeRendering
            antialiasing: false
            font.hintingPreference: Font.PreferFullHinting
            color: Theme.on_primary_container
            visible: Notifications.list.length > 0
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 6
            spacing: 4

            // Silent toggle
            Rectangle {
                width: silentContent.implicitWidth + 16
                height: 26
                radius: 0
                color: Notifications.silent ? Theme.primary
                    : silentHover.hovered ? Qt.rgba(0,0,0,0.12) : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }

                Row {
                    id: silentContent
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "󱋬"
                        font.pixelSize: 16
                        font.family: Settings.iconFont
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: Notifications.silent ? Theme.on_primary : Theme.on_primary_container
                    }
                    Text {
                        text: "Silent"
                        font.pixelSize: 16
                        font.family: Settings.iconFont
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: Notifications.silent ? Theme.on_primary : Theme.on_primary_container
                    }
                }
                HoverHandler { id: silentHover }
                TapHandler { onTapped: Notifications.silent = !Notifications.silent }
            }

            // Clear all
            Rectangle {
                width: clearContent.implicitWidth + 16
                height: 26
                radius: 0
                color: clearHover.hovered ? Qt.rgba(0,0,0,0.12) : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }

                Row {
                    id: clearContent
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "󱘕"
                        font.pixelSize: 16
                        font.family: Settings.iconFont
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: Theme.on_primary_container
                    }
                    Text {
                        text: "Clear"
                        font.pixelSize: 16
                        font.family: Settings.iconFont
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: Theme.on_primary_container
                    }
                }
                HoverHandler { id: clearHover }
                TapHandler { onTapped: Notifications.discardAllNotifications() }
            }
        }
    }
}
