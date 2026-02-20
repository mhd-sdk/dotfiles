import Quickshell
import Quickshell.Wayland
import QtQuick

Scope {
    id: root

    required property var modelData
    property int thickness: 11

    PanelWindow {
        screen: root.modelData
        anchors.right: true
        exclusiveZone: root.thickness
        mask: Region {}
        implicitWidth: 1
        implicitHeight: 1
    }

    PanelWindow {
        screen: root.modelData
        anchors.bottom: true
        exclusiveZone: root.thickness
        mask: Region {}
        implicitWidth: 1
        implicitHeight: 1
    }

    PanelWindow {
        screen: root.modelData
        anchors.left: true
        exclusiveZone: root.thickness
        mask: Region {}
        implicitWidth: 1
        implicitHeight: 1
    }
}
