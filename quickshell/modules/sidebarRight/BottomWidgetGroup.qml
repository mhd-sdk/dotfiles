import qs
import qs.services
import QtQuick
import QtQuick.Layouts
import "./calendar"

Rectangle {
    id: root
    radius: 0
    color: Theme.surface_container
    clip: true

    property bool collapsed: false

    implicitHeight: collapsed
        ? collapsedRow.implicitHeight + 12
        : calendarArea.implicitHeight + 12

    Behavior on implicitHeight {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }

    // ── Collapsed view ─────────────────────────────────────────────────────
    RowLayout {
        id: collapsedRow
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 10
            rightMargin: 10
        }
        visible: root.collapsed
        opacity: root.collapsed ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        // Expand button
        Rectangle {
            width: 28
            height: 28
            radius: 0
            color: expandHover.hovered ? Qt.rgba(0,0,0,0.12) : "transparent"
            Behavior on color { ColorAnimation { duration: 120 } }

            Text {
                anchors.centerIn: parent
                text: "󰅃"
                font.pixelSize: 16
                font.family: Settings.iconFont
                renderType: Text.NativeRendering
                antialiasing: false
                font.hintingPreference: Font.PreferFullHinting
                color: Theme.on_surface
            }
            HoverHandler { id: expandHover }
            TapHandler { onTapped: root.collapsed = false }
        }

        Text {
            Layout.fillWidth: true
            text: Time.format("ddd dd MMMM yyyy")
            font.pixelSize: 16
            font.family: Settings.font
            renderType: Text.NativeRendering
            antialiasing: false
            font.hintingPreference: Font.PreferFullHinting
            color: Theme.on_surface
        }
    }

    // ── Expanded view ──────────────────────────────────────────────────────
    Item {
        id: calendarArea
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        implicitHeight: calendarHeader.height + calendar.implicitHeight + 6

        visible: !root.collapsed
        opacity: !root.collapsed ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        // Header row with collapse button
        RowLayout {
            id: calendarHeader
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: 10
                rightMargin: 10
                topMargin: 6
            }
            height: 28

            // Collapse button
            Rectangle {
                width: 28
                height: 28
                radius: 0
                color: collapseHover.hovered ? Qt.rgba(0,0,0,0.12) : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: "󰅀"
                    font.pixelSize: 16
                    font.family: Settings.iconFont
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_surface
                }
                HoverHandler { id: collapseHover }
                TapHandler { onTapped: root.collapsed = true }
            }

            Item { Layout.fillWidth: true }
        }

        CalendarWidget {
            id: calendar
            anchors {
                top: calendarHeader.bottom
                left: parent.left
                right: parent.right
                topMargin: 2
            }
        }
    }
}
