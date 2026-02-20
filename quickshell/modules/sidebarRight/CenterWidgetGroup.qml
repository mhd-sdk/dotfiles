import qs
import qs.services
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./notifications"
import "./volumeMixer"

Rectangle {
    id: root
    radius: 0
    color: Theme.primary_container

    property int selectedTab: 0
    readonly property var tabs: [
        { icon: "󱅫", label: "Notifs" },
        { icon: "󰕾", label: "Audio"  }
    ]

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Tab bar ────────────────────────────────────────────────────────
        Row {
            id: tabBar
            Layout.fillWidth: true
            height: 36

            Repeater {
                model: root.tabs
                Item {
                    id: tabItem
                    width: tabBar.width / root.tabs.length
                    height: tabBar.height
                    property int tabIndex: index

                    Rectangle {
                        anchors.fill: parent
                        color: root.selectedTab === tabItem.tabIndex
                            ? Qt.rgba(0,0,0,0.15)
                            : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: modelData.icon
                            font.pixelSize: 16
                            font.family: Settings.iconFont
                            renderType: Text.NativeRendering
                            antialiasing: false
                            font.hintingPreference: Font.PreferFullHinting
                            color: root.selectedTab === tabItem.tabIndex
                                ? Theme.primary : Theme.on_primary_container
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        Text {
                            text: modelData.label
                            font.pixelSize: 16
                            font.family: Settings.font
                            renderType: Text.NativeRendering
                            antialiasing: false
                            font.hintingPreference: Font.PreferFullHinting
                            color: root.selectedTab === tabItem.tabIndex
                                ? Theme.primary : Theme.on_primary_container
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    TapHandler {
                        onTapped: root.selectedTab = tabItem.tabIndex
                    }
                }
            }
        }

        // ── Tab indicator ──────────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            height: 2

            Rectangle {
                width: parent.width
                height: parent.height
                color: Qt.rgba(0,0,0,0.2)
            }
            Rectangle {
                width: parent.width / root.tabs.length
                height: parent.height
                color: Theme.primary
                x: root.selectedTab * (parent.width / root.tabs.length)
                Behavior on x {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }
            }
        }

        // ── Tab content ────────────────────────────────────────────────────
        StackLayout {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.selectedTab

            NotificationList {
                clip: true
            }

            VolumeMixer {
                clip: true
            }
        }
    }
}
