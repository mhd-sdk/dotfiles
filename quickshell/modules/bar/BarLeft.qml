import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    color: "transparent"
    height: parent.height
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: 0

    // Size to fit workspaces content
    width: workspaces.implicitWidth

    Workspaces {
        id: workspaces
    }
}
