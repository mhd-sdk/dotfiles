import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import qs

PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    property int thickness: 6
    property int barHeight: 25
    property int cornerRadius: 0

    anchors.top: true
    anchors.left: true
    anchors.right: true
    anchors.bottom: true

    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    color: "transparent"
    mask: Region {}

    Item {
        anchors.fill: parent

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            blurMax: 40
            shadowColor: Qt.alpha(Theme.shadow, 0.85)
            shadowBlur: 0.7
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.background

            layer.enabled: true
            layer.effect: MultiEffect {
                maskSource: borderMask
                maskEnabled: true
                maskInverted: true
                maskThresholdMin: 0.5
                maskSpreadAtMin: 0.5
            }
        }
    }

    Item {
        id: borderMask
        anchors.fill: parent
        layer.enabled: true
        visible: false

        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: root.barHeight - root.thickness
        }

        Rectangle {
            x: root.thickness
            y: root.barHeight
            width: parent.width - root.thickness * 2
            height: parent.height - root.barHeight - root.thickness
            radius: root.cornerRadius
        }
    }
}
