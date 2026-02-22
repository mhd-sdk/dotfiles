import qs
import qs.services
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root
    property int sidebarWidth: 460

    // Force BrightnessService to init at startup so detect runs in background
    Connections {
        target: BrightnessService
        function onReadyChanged() {}
    }
    property bool _panelVisible: false
    property bool _hasLoaded: false

    PanelWindow {
        id: sidebarRoot
        visible: root._panelVisible

        function hide() {
            GlobalState.sidebarRightOpen = false;
            openAnim.stop();
            closeAnim.start();
        }

        Connections {
            target: GlobalState
            function onSidebarRightOpenChanged() {
                if (GlobalState.sidebarRightOpen) {
                    root._panelVisible = true;
                    root._hasLoaded = true;
                    closeAnim.stop();
                    openAnim.start();
                }
            }
        }

        NumberAnimation {
            id: openAnim
            target: sidebarContentLoader
            property: "x"
            to: 0
            duration: 620
            easing.type: Easing.OutExpo
        }

        NumberAnimation {
            id: closeAnim
            target: sidebarContentLoader
            property: "x"
            to: root.sidebarWidth
            duration: 620
            easing.type: Easing.OutExpo
            onFinished: {
                root._panelVisible = false;
                sidebarContentLoader.x = root.sidebarWidth;
            }
        }

        exclusiveZone: 0
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        implicitWidth: sidebarWidth
        implicitHeight: screen.height - 25
        WlrLayershell.namespace: "quickshell:sidebarRight"
        color: "transparent"

        anchors {
            right: true
            bottom: true
        }

        HyprlandFocusGrab {
            id: grab
            windows: [sidebarRoot]
            active: GlobalState.sidebarRightOpen
            onCleared: {
                if (!active)
                    sidebarRoot.hide();
            }
        }

        Item {
            anchors.fill: parent
            clip: true

            Loader {
                id: sidebarContentLoader
                active: root._panelVisible || root._hasLoaded
                x: root.sidebarWidth
                y: 0
                width: parent.width - 6
                height: parent.height
                focus: GlobalState.sidebarRightOpen
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape)
                        sidebarRoot.hide();
                }
                sourceComponent: Component {
                    SidebarRightContent {
                        screenName: GlobalState.sidebarRightScreen
                    }
                }
            }
        }
    }
}
