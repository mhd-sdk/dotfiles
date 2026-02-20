import qs
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root
    property int sidebarWidth: 460

    PanelWindow {
        id: sidebarRoot
        visible: GlobalState.sidebarRightOpen

        function hide() {
            GlobalState.sidebarRightOpen = false
        }

        exclusiveZone: 0
        implicitWidth: sidebarWidth
        WlrLayershell.namespace: "quickshell:sidebarRight"
        color: "transparent"

        anchors {
            top: true
            right: true
            bottom: true
        }

        HyprlandFocusGrab {
            id: grab
            windows: [sidebarRoot]
            active: GlobalState.sidebarRightOpen
            onCleared: {
                if (!active) sidebarRoot.hide()
            }
        }

        Loader {
            id: sidebarContentLoader
            active: GlobalState.sidebarRightOpen
            anchors {
                fill: parent
                margins: 5
                leftMargin: 10
            }
            focus: GlobalState.sidebarRightOpen
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) sidebarRoot.hide()
            }
            sourceComponent: SidebarRightContent {}
        }
    }
}
