import qs
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

Item {
    id: root
    required property Notification notification
    property bool expanded: false

    implicitHeight: bg.implicitHeight

    Rectangle {
        id: bg
        width: parent.width
        radius: 0
        color: root.expanded
            ? (root.notification?.urgency === NotificationUrgency.Critical
               ? Qt.lighter(Theme.error_container, 1.1)
               : Qt.rgba(0,0,0,0.2))
            : Qt.rgba(0,0,0,0.1)
        implicitHeight: content.implicitHeight + 10 * 2
        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on implicitHeight {
            NumberAnimation { duration: 300; easing.type: Easing.BezierSpline; easing.bezierCurve: [0.2, 1.0, 0.0, 1.0, 1.0, 1.0] }
        }

        ColumnLayout {
            id: content
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 10
            }
            spacing: 4

            // ── Summary row ──────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                // App name
                Text {
                    visible: root.notification?.appName?.length > 0
                    text: root.notification?.appName ?? ""
                    font.pixelSize: 16
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_surface
                }

                Text {
                    visible: (root.notification?.appName?.length > 0) && !root.expanded
                    text: "•"
                    font.pixelSize: 16
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_surface
                }

                Text {
                    Layout.fillWidth: true
                    text: root.notification?.summary ?? ""
                    font.pixelSize: 16
                    font.bold: true
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: root.notification?.urgency === NotificationUrgency.Critical
                        ? Theme.error : Theme.on_surface
                    elide: Text.ElideRight
                }

                // Inline body preview when collapsed
                Text {
                    Layout.fillWidth: true
                    visible: !root.expanded && (root.notification?.body?.length > 0)
                    opacity: !root.expanded ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                    text: root.notification?.body?.replace(/\n/g, " ") ?? ""
                    font.pixelSize: 16
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_surface
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }

            // ── Expanded body + actions ─────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                visible: root.expanded
                opacity: root.expanded ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                Text {
                    Layout.fillWidth: true
                    text: root.notification?.body ?? ""
                    font.pixelSize: 16
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_surface
                    wrapMode: Text.Wrap
                }

                // Actions row
                Row {
                    Layout.fillWidth: true
                    spacing: 6
                    topPadding: 4

                    // Dismiss button
                    Rectangle {
                        height: 28
                        width: dismissTxt.implicitWidth + 16
                        radius: 0
                        color: dismissHover.hovered ? Qt.rgba(0,0,0,0.25) : Qt.rgba(0,0,0,0.15)
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            id: dismissTxt
                            anchors.centerIn: parent
                            text: "Dismiss"
                            font.pixelSize: 16
                            font.family: Settings.font
                            renderType: Text.NativeRendering
                            antialiasing: false
                            font.hintingPreference: Font.PreferFullHinting
                            color: Theme.on_surface
                        }
                        HoverHandler { id: dismissHover }
                        TapHandler {
                            onTapped: Notifications.discardNotification(root.notification?.id ?? -1)
                        }
                    }

                    // Notification actions
                    Repeater {
                        model: root.notification?.actions ?? []
                        Rectangle {
                            required property var modelData
                            height: 28
                            width: actionTxt.implicitWidth + 16
                            radius: 0
                            color: actionHover.hovered ? Qt.lighter(Theme.primary, 1.1) : Theme.primary
                            Behavior on color { ColorAnimation { duration: 120 } }

                            Text {
                                id: actionTxt
                                anchors.centerIn: parent
                                text: modelData.text
                                font.pixelSize: 16
                                font.family: Settings.font
                                renderType: Text.NativeRendering
                                antialiasing: false
                                font.hintingPreference: Font.PreferFullHinting
                                color: Theme.on_primary
                            }
                            HoverHandler { id: actionHover }
                            TapHandler {
                                onTapped: {
                                    root.notification?.invokeAction(modelData.identifier)
                                    Notifications.discardNotification(root.notification?.id ?? -1)
                                }
                            }
                        }
                    }
                }
            }
        }

        TapHandler {
            onTapped: root.expanded = !root.expanded
        }
    }
}
