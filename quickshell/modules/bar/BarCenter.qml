import QtQuick
import Quickshell

import qs

Item {
    id: root
    height: parent.height
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter

    implicitWidth: clockText.implicitWidth + 16

    property string timeFormat: "ddd dd MMM  HH:mm"

    Timer {
        id: tick
        interval: 1000
        repeat: true
        running: true
        onTriggered: clockText.text = Qt.formatDateTime(new Date(), root.timeFormat)
    }

    Text {
        id: clockText
        anchors.centerIn: parent
        text: Qt.formatDateTime(new Date(), root.timeFormat)
        color: Theme.on_surface_variant
        font.pixelSize: 14
        font.family: Settings.font
        renderType: Text.NativeRendering
        antialiasing: false
        font.hintingPreference: Font.PreferFullHinting
    }
}
