import qs
import qs.services
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root

    property bool osdVisible: false
    property var targetScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name)
                               ?? Quickshell.screens[0]

    function show() {
        if (GlobalState.sidebarRightOpen) return
        osdWin.screen = root.targetScreen
        osdVisible = true
        hideTimer.restart()
    }

    Timer {
        id: hideTimer
        interval: 1500
        repeat: false
        onTriggered: root.osdVisible = false
    }

    Connections {
        target: VolumeService
        function onVolumeChanged() { root.show() }
        function onMutedChanged() { root.show() }
    }

    PanelWindow {
        id: osdWin
        visible: root.osdVisible
        color: "transparent"
        exclusiveZone: 0
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell:osd"

        anchors { bottom: true }
        margins.bottom: 60
        implicitWidth: osdBg.implicitWidth
        implicitHeight: osdBg.implicitHeight

        Rectangle {
            id: osdBg
            implicitWidth: osdRow.implicitWidth + 24
            implicitHeight: osdRow.implicitHeight + 16
            color: Theme.surface_container_high
            radius: 0

            Row {
                id: osdRow
                anchors.centerIn: parent
                spacing: 10

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: VolumeService.muted ? "󰝟"
                        : VolumeService.volume < 0.35 ? "󰕿"
                        : VolumeService.volume < 0.7 ? "󰖀" : "󰕾"
                    font.pixelSize: 16
                    font.family: Settings.iconFont
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_surface
                }

                Item {
                    width: 160
                    height: 18
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 4
                        color: Theme.outline_variant
                    }
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: VolumeService.volume * parent.width
                        height: 4
                        color: Theme.primary
                        Behavior on width { NumberAnimation { duration: 80 } }
                    }
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        x: VolumeService.volume * (parent.width - width)
                        width: 12
                        height: 12
                        color: Theme.primary
                        Behavior on x { NumberAnimation { duration: 80 } }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: VolumeService.muted ? "muted"
                        : Math.round(VolumeService.volume * 100) + "%"
                    font.pixelSize: 16
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_surface
                    width: 46
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }
}
