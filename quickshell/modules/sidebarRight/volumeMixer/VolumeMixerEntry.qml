import qs
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire

Item {
    id: root
    required property PwNode node

    PwObjectTracker { objects: [root.node] }

    implicitHeight: row.implicitHeight + 4

    RowLayout {
        id: row
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        spacing: 8

        // App name + volume slider
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: {
                    const app = root.node.properties["application.name"]
                        ?? (root.node.description !== "" ? root.node.description : root.node.name)
                    const media = root.node.properties["media.name"]
                    return media !== undefined ? app + " • " + media : app
                }
                font.pixelSize: 16
                font.family: Settings.font
                renderType: Text.NativeRendering
                antialiasing: false
                font.hintingPreference: Font.PreferFullHinting
                color: Theme.on_primary_container
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                // Volume slider (raw Rectangle-based)
                Item {
                    Layout.fillWidth: true
                    height: 18

                    // Track background
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 4
                        radius: 0
                        color: Theme.on_primary_container_variant
                    }

                    // Fill
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.min(1, root.node.audio.volume) * parent.width
                        height: 4
                        radius: 0
                        color: Theme.primary
                    }

                    // Thumb
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        x: Math.min(1, root.node.audio.volume) * (parent.width - width)
                        width: 12
                        height: 12
                        radius: 0
                        color: Theme.primary

                        Behavior on x {
                            enabled: !sliderArea.pressed
                            NumberAnimation { duration: 100 }
                        }
                    }

                    // Interaction area
                    MouseArea {
                        id: sliderArea
                        anchors.fill: parent
                        onPositionChanged: mouse => {
                            if (pressed) {
                                root.node.audio.volume = Math.max(0, Math.min(1, mouse.x / width))
                            }
                        }
                        onClicked: mouse => {
                            root.node.audio.volume = Math.max(0, Math.min(1, mouse.x / width))
                        }
                    }
                }

                // Volume percentage
                Text {
                    text: Math.round(root.node.audio.volume * 100) + "%"
                    font.pixelSize: 16
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_primary_container
                    Layout.minimumWidth: 32
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }
}
