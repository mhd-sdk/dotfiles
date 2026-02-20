import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import qs

PanelWindow {
    id: win
    implicitHeight: 25
    required property var modelData
    screen: modelData

    anchors.top: true
    anchors.left: true
    anchors.right: true

    WlrLayershell.exclusiveZone: 25 + 5

    Rectangle {
        color: Theme.background
        anchors.fill: parent

        BarLeft {}
        BarCenter {}
        BarRight {}
    }
}
