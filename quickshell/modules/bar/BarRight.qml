import QtQuick
import Quickshell
import Quickshell.Io
import qs

Item {
    id: root

    height: parent.height
    anchors.right: parent.right
    implicitWidth: row.implicitWidth + 12

    // CPU Temperature
    property string cpuTemp: "..."
    Process {
        id: cpuTempProcess
        running: true
        command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone0/temp"]
        stdout: SplitParser {
            onRead: data => {
                const temp = parseInt(data) / 1000
                root.cpuTemp = Math.round(temp) + "°C"
            }
        }
    }
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: cpuTempProcess.running = true
    }

    // IP Address
    property string ipAddress: "..."
    Process {
        id: ipProcess
        running: true
        command: ["sh", "-c", "ip -4 addr show | grep -oP '(?<=inet\\s)\\d+(\\.\\d+){3}' | grep -v 127.0.0.1 | head -n1"]
        stdout: SplitParser {
            onRead: data => {
                root.ipAddress = data.trim() || "N/A"
            }
        }
    }
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: ipProcess.running = true
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 6
        spacing: 0

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.cpuTemp
            font.pixelSize: 14
            font.family: Settings.font
            renderType: Text.NativeRendering
            antialiasing: false
            font.hintingPreference: Font.PreferFullHinting
            color: Theme.on_surface_variant
            rightPadding: 8
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.ipAddress
            font.pixelSize: 14
            font.family: Settings.font
            renderType: Text.NativeRendering
            antialiasing: false
            font.hintingPreference: Font.PreferFullHinting
            color: Theme.on_surface_variant
            rightPadding: 8
        }

        // Menu button
        Rectangle {
            id: menuBtn
            width: root.height
            height: root.height
            radius: 0
            color: GlobalState.sidebarRightOpen ? Theme.primary
                : menuHover.hovered ? Theme.surface_container_high
                : "transparent"
            Behavior on color { ColorAnimation { duration: 120 } }

            Text {
                id: menuIcon
                anchors.centerIn: parent
                text: "󰍜"
                font.pixelSize: 14
                font.family: Settings.iconFont
                renderType: Text.NativeRendering
                antialiasing: false
                font.hintingPreference: Font.PreferFullHinting
                color: GlobalState.sidebarRightOpen ? Theme.on_primary : Theme.on_surface_variant
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            HoverHandler { id: menuHover }

            TapHandler {
                onTapped: GlobalState.sidebarRightOpen = !GlobalState.sidebarRightOpen
            }
        }
    }
}
