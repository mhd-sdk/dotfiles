import QtQuick
import qs
import qs.services

// Calendar widget — custom grid, no Qt.labs.calendar dependency
Item {
    id: root

    width: parent?.width ?? 280
    implicitHeight: calCol.implicitHeight + 16

    property int currentMonth: Number(Time.format("MM")) - 1
    property int currentYear: Number(Time.format("yyyy"))

    // Changes once per day — used to avoid re-evaluating calendarDays every second
    readonly property string todayDateStr: Time.format("yyyy-MM-dd")

    // Build the 6×7 day grid (or fewer rows) for the current month view
    property var calendarDays: {
        const year = root.currentYear
        const month = root.currentMonth
        const firstDay = new Date(year, month, 1)
        const lastDayNum = new Date(year, month + 1, 0).getDate()
        const firstWeekday = firstDay.getDay()  // Sunday=0 … Saturday=6
        const parts = root.todayDateStr.split("-").map(Number)
        const today = { getFullYear: () => parts[0], getMonth: () => parts[1]-1, getDate: () => parts[2] }

        const days = []

        // Leading days from previous month
        for (let i = 0; i < firstWeekday; i++) {
            const d = new Date(year, month, 1 - firstWeekday + i)
            days.push({ date: d, inMonth: false, isToday: false })
        }

        // Days of current month
        for (let d = 1; d <= lastDayNum; d++) {
            const date = new Date(year, month, d)
            const isToday = date.getFullYear() === today.getFullYear()
                         && date.getMonth()    === today.getMonth()
                         && date.getDate()     === today.getDate()
            days.push({ date: date, inMonth: true, isToday: isToday })
        }

        // Trailing days to complete last row
        while (days.length % 7 !== 0) {
            const trailing = days.length - firstWeekday - lastDayNum + 1
            days.push({ date: new Date(year, month + 1, trailing), inMonth: false, isToday: false })
        }

        return days
    }

    Column {
        id: calCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 8
        spacing: 4

        // ── Month navigation header ─────────────────────────────────────────
        Item {
            width: parent.width
            height: 20

            Text {
                id: prevBtn
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "<"
                width: 20
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 14
                font.family: Settings.font
                renderType: Text.NativeRendering
                antialiasing: false
                font.hintingPreference: Font.PreferFullHinting
                color: prevArea.containsMouse ? Theme.on_surface : Theme.on_surface_variant

                MouseArea {
                    id: prevArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.currentMonth--
                        if (root.currentMonth < 0) { root.currentMonth = 11; root.currentYear-- }
                    }
                }
            }

            Text {
                anchors.left: prevBtn.right
                anchors.right: nextBtn.left
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                text: Qt.locale("en_US").standaloneMonthName(root.currentMonth) + " " + root.currentYear
                font.pixelSize: 14
                font.bold: true
                font.family: Settings.font
                renderType: Text.NativeRendering
                antialiasing: false
                font.hintingPreference: Font.PreferFullHinting
                color: Theme.on_surface
            }

            Text {
                id: nextBtn
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: ">"
                width: 20
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 14
                font.family: Settings.font
                renderType: Text.NativeRendering
                antialiasing: false
                font.hintingPreference: Font.PreferFullHinting
                color: nextArea.containsMouse ? Theme.on_surface : Theme.on_surface_variant

                MouseArea {
                    id: nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.currentMonth++
                        if (root.currentMonth > 11) { root.currentMonth = 0; root.currentYear++ }
                    }
                }
            }
        }

        // ── Day-of-week header ──────────────────────────────────────────────
        Row {
            width: parent.width
            height: 18

            Repeater {
                model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                Text {
                    required property string modelData
                    required property int index
                    width: calCol.width / 7
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    font.pixelSize: 14
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_surface_variant
                }
            }
        }

        // ── Month grid ──────────────────────────────────────────────────────
        Grid {
            id: monthGrid
            width: parent.width
            columns: 7

            Repeater {
                model: root.calendarDays

                Item {
                    required property var modelData
                    required property int index
                    width: monthGrid.width / 7
                    height: 18

                    Rectangle {
                        anchors.fill: parent
                        color: modelData.isToday ? Theme.primary
                             : (dayHover.containsMouse && modelData.inMonth ? Theme.surface_container_high : "transparent")
                    }

                    Text {
                        anchors.centerIn: parent
                        text: modelData.date.getDate()
                        font.pixelSize: 14
                        font.family: Settings.font
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: {
                            if (modelData.isToday) return Theme.on_primary
                            if (!modelData.inMonth) return Theme.outline_variant
                            const dow = modelData.date.getDay()
                            return (dow === 0 || dow === 6) ? Theme.error : Theme.on_surface
                        }
                    }

                    HoverHandler { id: dayHover }
                }
            }
        }

        // ── Today + moon phase ──────────────────────────────────────────────
        Item {
            width: parent.width
            height: 18

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: Time.format("dddd, MMMM d")
                font.pixelSize: 14
                font.family: Settings.font
                renderType: Text.NativeRendering
                antialiasing: false
                font.hintingPreference: Font.PreferFullHinting
                color: Theme.on_surface_variant
            }

            // Moon phase circle
            Item {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 14
                height: 14

                Rectangle {
                    anchors.fill: parent
                    color: Theme.on_surface
                    clip: true

                    Rectangle {
                        width: parent.width
                        height: parent.height
                        color: Theme.surface_container
                        property real phase: Time.synodicDays / 29.53059
                        property real dir: phase < 0.5 ? -1 : 1
                        x: dir * width * (1 - Math.abs(1 - 2 * phase))
                    }
                }
            }
        }
    }
}
