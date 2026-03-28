pragma ComponentBehavior: Bound

import qs
import qs.services
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Notifications

Scope {
    id: root

    property var currentNotification: null
    property bool toastVisible: false
    property bool windowVisible: false
    property real progress: 1.0

    property var targetScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name)
                               ?? Quickshell.screens[0]

    function show(notification) {
        if (Notifications.silent) return
        currentNotification = notification
        toastWin.screen = root.targetScreen
        windowVisible = true
        toastVisible = true
        progress = 1.0
        progressAnim.restart()
        hideTimer.restart()
    }

    function dismiss() {
        toastVisible = false
        hideTimer.stop()
        progressAnim.stop()
        windowHideTimer.restart()
    }

    Connections {
        target: Notifications
        function onNotificationReceived(notification) { root.show(notification) }
    }

    Timer {
        id: hideTimer
        interval: 5000
        repeat: false
        onTriggered: root.dismiss()
    }

    Timer {
        id: windowHideTimer
        interval: 350
        repeat: false
        onTriggered: root.windowVisible = false
    }

    NumberAnimation {
        id: progressAnim
        target: root
        property: "progress"
        from: 1.0; to: 0.0
        duration: 5000
        easing.type: Easing.Linear
    }

    PanelWindow {
        id: toastWin
        visible: root.windowVisible
        color: "transparent"
        exclusiveZone: 0
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell:toast"

        anchors { top: true; right: true }
        margins.top: 34
        margins.right: 0
        implicitWidth: 320
        implicitHeight: toastItem.implicitHeight

        Item {
            id: toastItem
            width: parent.width
            implicitHeight: toastBg.implicitHeight

            opacity: root.toastVisible ? 1.0 : 0.0
            y: root.toastVisible ? 0 : -12

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.2, 1.0, 0.0, 1.0, 1.0, 1.0]
                }
            }
            Behavior on y {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.2, 1.0, 0.0, 1.0, 1.0, 1.0]
                }
            }

            Rectangle {
                id: toastBg
                width: parent.width
                color: Theme.surface_container_high
                radius: 0
                implicitHeight: innerCol.implicitHeight + 12 * 2

                // Left urgency accent
                Rectangle {
                    width: 3
                    height: parent.height
                    color: root.currentNotification?.urgency === NotificationUrgency.Critical
                        ? Theme.error : Theme.primary
                }

                // Dismiss on click
                TapHandler { onTapped: root.dismiss() }

                // Content
                Column {
                    id: innerCol
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        leftMargin: 14
                        rightMargin: 14
                        topMargin: 12
                    }
                    spacing: 3

                    // App name
                    Text {
                        width: parent.width - 18
                        visible: (root.currentNotification?.appName?.length ?? 0) > 0
                        text: root.currentNotification?.appName ?? ""
                        font.pixelSize: 16
                        font.family: Settings.font
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: Theme.on_surface_variant
                        elide: Text.ElideRight
                    }

                    // Summary
                    Text {
                        width: parent.width - 18
                        text: root.currentNotification?.summary ?? ""
                        font.pixelSize: 16
                        font.bold: true
                        font.family: Settings.font
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: root.currentNotification?.urgency === NotificationUrgency.Critical
                            ? Theme.error : Theme.on_surface
                        elide: Text.ElideRight
                    }

                    // Body
                    Text {
                        width: parent.width
                        visible: (root.currentNotification?.body?.length ?? 0) > 0
                        text: root.currentNotification?.body ?? ""
                        font.pixelSize: 16
                        font.family: Settings.font
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: Theme.on_surface_variant
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }

                    // Progress bar
                    Item {
                        width: parent.width
                        height: 7

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 3
                            color: Theme.outline_variant
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width * root.progress
                            height: 3
                            color: root.currentNotification?.urgency === NotificationUrgency.Critical
                                ? Theme.error : Theme.primary
                        }
                    }
                }

                // Close button
                Text {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 10
                    anchors.rightMargin: 10
                    text: "×"
                    font.pixelSize: 16
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_surface_variant

                    TapHandler { onTapped: root.dismiss() }
                }
            }
        }
    }
}
