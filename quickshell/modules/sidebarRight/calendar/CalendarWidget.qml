import qs
import QtQuick
import QtQuick.Layouts
import "./calendar_layout.js" as CalendarLayout

Item {
    id: root
    implicitHeight: calendarColumn.implicitHeight + 8
    anchors.left: parent?.left
    anchors.right: parent?.right
    anchors.leftMargin: 10
    anchors.rightMargin: 10

    property int monthShift: 0
    property var viewingDate: CalendarLayout.getDateInXMonthsTime(monthShift)
    property var calendarLayout: CalendarLayout.getCalendarLayout(viewingDate, monthShift === 0)

    MouseArea {
        anchors.fill: parent
        onWheel: event => {
            if (event.angleDelta.y > 0) monthShift--
            else if (event.angleDelta.y < 0) monthShift++
        }
    }

    ColumnLayout {
        id: calendarColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 4

        // ── Month navigation header ─────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            // Month+year label (click to go back to current)
            Text {
                Layout.fillWidth: true
                text: (root.monthShift !== 0 ? "• " : "") +
                      root.viewingDate.toLocaleDateString(Qt.locale(), "MMMM yyyy")
                font.pixelSize: 16
                font.family: Settings.font
                renderType: Text.NativeRendering
                antialiasing: false
                font.hintingPreference: Font.PreferFullHinting
                color: root.monthShift !== 0 ? Theme.primary : Theme.on_primary_container
                Behavior on color { ColorAnimation { duration: 150 } }

                TapHandler {
                    enabled: root.monthShift !== 0
                    onTapped: root.monthShift = 0
                }
            }

            // Prev month
            Rectangle {
                width: 24
                height: 24
                radius: 0
                color: prevHover.hovered ? Qt.rgba(0,0,0,0.12) : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }
                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.pixelSize: 16
                    font.family: Settings.iconFont
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_primary_container
                }
                HoverHandler { id: prevHover }
                TapHandler { onTapped: root.monthShift-- }
            }

            // Next month
            Rectangle {
                width: 24
                height: 24
                radius: 0
                color: nextHover.hovered ? Qt.rgba(0,0,0,0.12) : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }
                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.pixelSize: 16
                    font.family: Settings.iconFont
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_primary_container
                }
                HoverHandler { id: nextHover }
                TapHandler { onTapped: root.monthShift++ }
            }
        }

        // ── Week day headers ────────────────────────────────────────────────
        Row {
            Layout.fillWidth: true
            spacing: 2

            Repeater {
                model: CalendarLayout.weekDays
                Text {
                    width: (calendarColumn.width - 6 * 2) / 7
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData.day
                    font.pixelSize: 16
                    font.bold: true
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_primary_container
                }
            }
        }

        // ── Calendar grid (6 weeks) ─────────────────────────────────────────
        Repeater {
            model: 6
            Row {
                property int weekIndex: index
                Layout.fillWidth: true
                spacing: 2

                Repeater {
                    model: 7
                    Rectangle {
                        property var dayData: root.calendarLayout[weekIndex][index]
                        property bool isToday: dayData ? dayData.today === 1 : false
                        property bool isCurrentMonth: dayData ? dayData.today !== -1 : false

                        width: (calendarColumn.width - 6 * 2) / 7
                        height: width
                        radius: 0
                        color: isToday ? Theme.primary
                            : dayHover.hovered && isCurrentMonth ? Qt.rgba(0,0,0,0.12)
                            : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text: dayData ? dayData.day : ""
                            font.pixelSize: 16
                            font.family: Settings.font
                            renderType: Text.NativeRendering
                            antialiasing: false
                            font.hintingPreference: Font.PreferFullHinting
                            color: isToday ? Theme.on_primary
                                : isCurrentMonth ? Theme.on_primary_container
                                : Qt.rgba(Theme.on_primary_container.r, Theme.on_primary_container.g, Theme.on_primary_container.b, 0.3)
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        HoverHandler { id: dayHover; enabled: isCurrentMonth }
                    }
                }
            }
        }
    }
}
