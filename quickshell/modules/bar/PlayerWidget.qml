import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs

// Media player list — one card per active MPRIS player
Column {
    id: root

    width: parent?.width ?? 280
    spacing: 0

    function formatTime(val: real): string {
        const totalSec = Math.floor(val)
        const min = Math.floor(totalSec / 60)
        const sec = totalSec % 60
        return ("0" + min).slice(-2) + ":" + ("0" + sec).slice(-2)
    }

    Repeater {
        model: Mpris.players

        delegate: Item {
            id: playerItem
            required property var modelData
            required property int index

            width: root.width
            implicitHeight: 120

            property real visualPosition: 0

            Timer {
                running: playerItem.modelData.isPlaying
                interval: 1000
                repeat: true
                onTriggered: {
                    playerItem.modelData.positionChanged()
                    if (playerItem.modelData.positionSupported)
                        playerItem.visualPosition = playerItem.modelData.position / 1000000
                }
            }

            Connections {
                target: playerItem.modelData
                function onPostTrackChanged() {
                    playerItem.visualPosition = 0
                }
            }

            Rectangle {
                anchors.fill: parent
                color: Theme.surface_container

                // Blurred album art background
                Image {
                    anchors.fill: parent
                    source: playerItem.modelData.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    opacity: 0.12
                    cache: true
                }

                Row {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    // Album art
                    Rectangle {
                        width: 56
                        height: 56
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.surface_container_high
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: playerItem.modelData.trackArtUrl ?? ""
                            fillMode: Image.PreserveAspectCrop
                        }
                    }

                    Column {
                        width: parent.width - 72
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3

                        // Track title
                        Text {
                            width: parent.width
                            text: playerItem.modelData.trackTitle || "Unknown"
                            elide: Text.ElideRight
                            font.pixelSize: 14
                            font.bold: true
                            font.family: Settings.font
                            renderType: Text.NativeRendering
                            antialiasing: false
                            font.hintingPreference: Font.PreferFullHinting
                            color: Theme.on_surface
                        }

                        // Artist
                        Text {
                            width: parent.width
                            text: playerItem.modelData.trackArtist || ""
                            elide: Text.ElideRight
                            font.pixelSize: 14
                            font.family: Settings.font
                            renderType: Text.NativeRendering
                            antialiasing: false
                            font.hintingPreference: Font.PreferFullHinting
                            color: Theme.on_surface_variant
                        }

                        // Playback controls
                        Row {
                            spacing: 12

                            Text {
                                visible: playerItem.modelData.canGoPrevious
                                text: ""
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
                                    onClicked: playerItem.modelData.previous()
                                }
                            }

                            Text {
                                visible: playerItem.modelData.canTogglePlaying
                                text: playerItem.modelData.isPlaying ? "" : ""
                                font.pixelSize: 14
                                font.family: Settings.font
                                renderType: Text.NativeRendering
                                antialiasing: false
                                font.hintingPreference: Font.PreferFullHinting
                                color: playArea.containsMouse ? Theme.primary : Theme.on_surface
                                MouseArea {
                                    id: playArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: playerItem.modelData.togglePlaying()
                                }
                            }

                            Text {
                                visible: playerItem.modelData.canGoNext
                                text: ""
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
                                    onClicked: playerItem.modelData.next()
                                }
                            }

                            // Shuffle
                            Text {
                                visible: playerItem.modelData.shuffleSupported
                                text: "󰒝"
                                font.pixelSize: 14
                                font.family: Settings.font
                                renderType: Text.NativeRendering
                                antialiasing: false
                                font.hintingPreference: Font.PreferFullHinting
                                color: (playerItem.modelData.shuffle ?? false) ? Theme.primary : Theme.on_surface_variant
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (playerItem.modelData.shuffleSupported)
                                            playerItem.modelData.shuffle = !playerItem.modelData.shuffle
                                    }
                                }
                            }
                        }

                        // Progress bar row
                        Row {
                            width: parent.width
                            spacing: 4
                            visible: playerItem.modelData.positionSupported && playerItem.modelData.length > 0

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.formatTime(playerItem.visualPosition)
                                font.pixelSize: 14
                                font.family: Settings.font
                                renderType: Text.NativeRendering
                                antialiasing: false
                                font.hintingPreference: Font.PreferFullHinting
                                color: Theme.on_surface_variant
                            }

                            Item {
                                width: parent.width - 68
                                height: 4
                                anchors.verticalCenter: parent.verticalCenter

                                Rectangle {
                                    anchors.fill: parent
                                    color: Theme.surface_container_highest
                                }
                                Rectangle {
                                    width: playerItem.modelData.length > 0
                                        ? Math.min(parent.width, parent.width * (playerItem.visualPosition / (playerItem.modelData.length / 1000000)))
                                        : 0
                                    height: parent.height
                                    color: Theme.primary
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: mouse => {
                                        const ratio = mouse.x / width
                                        playerItem.modelData.position = ratio * playerItem.modelData.length
                                        playerItem.visualPosition = ratio * playerItem.modelData.length / 1000000
                                    }
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.formatTime(playerItem.modelData.length / 1000000)
                                font.pixelSize: 14
                                font.family: Settings.font
                                renderType: Text.NativeRendering
                                antialiasing: false
                                font.hintingPreference: Font.PreferFullHinting
                                color: Theme.on_surface_variant
                            }
                        }
                    }
                }

                // Bottom divider
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: Theme.outline_variant
                }
            }
        }
    }

    // Empty state (height:0 when hidden so it doesn't occupy space in Column)
    Item {
        visible: Mpris.players.values.length === 0
        width: root.width
        height: visible ? 44 : 0
        implicitHeight: 44

        Text {
            anchors.centerIn: parent
            text: "no media playing"
            font.pixelSize: 14
            font.family: Settings.font
            renderType: Text.NativeRendering
            antialiasing: false
            font.hintingPreference: Font.PreferFullHinting
            color: Theme.on_surface_variant
        }
    }
}
