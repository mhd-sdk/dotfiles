import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Wayland
import qs
import qs.services

Item {
    id: root
    implicitHeight: parent.height
    implicitWidth: container.implicitWidth
    anchors.left: parent.left
    anchors.leftMargin: 7

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    property int workspaceButtonWidth: 25
    property real workspaceIconSize: 16
    property int workspaceCount: 9

    function activeWorkspaceIdForThisMonitor() {
        const mname = root.monitor ? root.monitor.name : null;
        if (!mname)
            return null;
        const monitors = HyprlandData.monitors || [];
        for (var i = 0; i < monitors.length; ++i) {
            const m = monitors[i];
            if (m.name === mname)
                return m.activeWorkspace ? m.activeWorkspace.id : null;
        }
        return null;
    }

    function workspaceOnThisMonitor(id) {
        const mname = root.monitor ? root.monitor.name : null;
        if (!mname)
            return false;
        const wss = HyprlandData.workspaces || [];
        for (var i = 0; i < wss.length; ++i) {
            const ws = wss[i];
            if (ws.id === id && ws.monitor === mname)
                return true;
        }
        return false;
    }

    // Container to stack moving background and row of buttons
    Item {
        id: container
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        implicitWidth: rowLayout.implicitWidth
        height: parent.height

        // Compute active index (0-based) for this monitor
        readonly property int activeIndex: {
            const id = root.activeWorkspaceIdForThisMonitor();
            return id ? (id - 1) : -1;
        }

        // Moving background indicator (square) behind active workspace
        Rectangle {
            id: activeBg
            z: 0
            y: 0
            width: (wsRepeater.itemAt(container.activeIndex) ? wsRepeater.itemAt(container.activeIndex).width : root.workspaceButtonWidth)
            height: parent.height
            radius: 0
            color: Theme.primary
            opacity: wsRepeater.itemAt(container.activeIndex) ? 1 : 0
            x: wsRepeater.itemAt(container.activeIndex) ? wsRepeater.itemAt(container.activeIndex).x : 0

            // Animate movement and resize between workspaces
            Behavior on x {
                NumberAnimation {
                    duration: 1000
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.2, 1.0, 0.0, 1.0, 1.0, 1.0]
                }
            }
            Behavior on width {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.InOutCubic
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                }
            }
        }

        RowLayout {
            id: rowLayout
            z: 1
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            spacing: 0

            Repeater {
                id: wsRepeater
                model: workspaceCount

                Rectangle {
                    id: wsButton
                    z: 1
                    implicitWidth: root.workspaceButtonWidth
                    implicitHeight: root.workspaceButtonWidth
                    radius: 0

                    readonly property int wsId: index + 1
                    readonly property bool isActive: root.activeWorkspaceIdForThisMonitor() === wsId

                    // Always transparent; active background is drawn by activeBg
                    color: "transparent"
                    border.width: 0

                    Text {
                        anchors.centerIn: parent
                        text: wsButton.wsId
                        font.pixelSize: 14
                        font.family: Settings.font
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        font.bold: wsButton.isActive
                        color: wsButton.isActive ? Theme.on_primary : Theme.on_surface_variant
                        Behavior on color {
                            ColorAnimation {
                                duration: 140
                            }
                        }
                    }
                }
            }
        }
    }
}
