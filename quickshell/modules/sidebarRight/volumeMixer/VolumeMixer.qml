import qs
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire

Item {
    id: root
    property bool showDeviceSelector: false
    property bool deviceSelectorInput: false
    property PwNode selectedDevice: null

    readonly property list<PwNode> appPwNodes: Pipewire.nodes.values.filter(node => {
        return node.isSink && node.isStream
    })

    function showDeviceSelectorDialog(input) {
        root.selectedDevice = null
        root.showDeviceSelector = true
        root.deviceSelectorInput = input
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── App stream list ────────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: listView
                anchors {
                    fill: parent
                    topMargin: 8
                    bottomMargin: 8
                }
                clip: true
                model: root.appPwNodes
                spacing: 6

                delegate: VolumeMixerEntry {
                    required property var modelData
                    node: modelData
                    anchors.left: parent?.left
                    anchors.right: parent?.right
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                }
            }

            // Empty placeholder
            Item {
                anchors.fill: listView
                visible: opacity > 0
                opacity: root.appPwNodes.length === 0 ? 1 : 0
                Behavior on opacity {
                    NumberAnimation { duration: 350; easing.type: Easing.OutExpo }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰕾"
                        font.pixelSize: 48
                        font.family: Settings.iconFont
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: Theme.on_primary_container
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "No audio source"
                        font.pixelSize: 16
                        font.family: Settings.iconFont
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: Theme.on_primary_container
                    }
                }
            }
        }

        // ── Device selector buttons ────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.on_primary_container_variant
        }

        Row {
            Layout.fillWidth: true
            height: 44

            // Output device button
            Rectangle {
                width: parent.width / 2
                height: parent.height
                radius: 0
                color: outHover.hovered ? Qt.rgba(0,0,0,0.12) : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }

                Column {
                    anchors.centerIn: parent
                    spacing: 1

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6

                        Text {
                            text: "󰕾"
                            font.pixelSize: 16
                            font.family: Settings.iconFont
                            renderType: Text.NativeRendering
                            antialiasing: false
                            font.hintingPreference: Font.PreferFullHinting
                            color: Theme.on_primary_container
                        }
                        Text {
                            text: "Output"
                            font.pixelSize: 16
                            font.family: Settings.iconFont
                            renderType: Text.NativeRendering
                            antialiasing: false
                            font.hintingPreference: Font.PreferFullHinting
                            color: Theme.on_primary_container
                        }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Pipewire.defaultAudioSink?.description ?? "Unknown"
                        font.pixelSize: 16
                        font.family: Settings.font
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: Theme.on_primary_container
                        elide: Text.ElideRight
                        width: Math.min(implicitWidth, parent.parent.parent.width / 2 - 20)
                    }
                }

                HoverHandler { id: outHover }
                TapHandler { onTapped: root.showDeviceSelectorDialog(false) }
            }

            Rectangle {
                width: 1
                height: parent.height
                color: Theme.on_primary_container_variant
            }

            // Input device button
            Rectangle {
                width: parent.width / 2 - 1
                height: parent.height
                radius: 0
                color: inHover.hovered ? Qt.rgba(0,0,0,0.12) : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }

                Column {
                    anchors.centerIn: parent
                    spacing: 1

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6

                        Text {
                            text: "󰍬"
                            font.pixelSize: 16
                            font.family: Settings.iconFont
                            renderType: Text.NativeRendering
                            antialiasing: false
                            font.hintingPreference: Font.PreferFullHinting
                            color: Theme.on_primary_container
                        }
                        Text {
                            text: "Input"
                            font.pixelSize: 16
                            font.family: Settings.iconFont
                            renderType: Text.NativeRendering
                            antialiasing: false
                            font.hintingPreference: Font.PreferFullHinting
                            color: Theme.on_primary_container
                        }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Pipewire.defaultAudioSource?.description ?? "Unknown"
                        font.pixelSize: 16
                        font.family: Settings.font
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: Theme.on_primary_container
                        elide: Text.ElideRight
                        width: Math.min(implicitWidth, parent.parent.parent.width / 2 - 20)
                    }
                }

                HoverHandler { id: inHover }
                TapHandler { onTapped: root.showDeviceSelectorDialog(true) }
            }
        }
    }

    // ── Device selector dialog ─────────────────────────────────────────────
    Item {
        anchors.fill: parent
        z: 9999
        visible: opacity > 0
        opacity: root.showDeviceSelector ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        // Scrim
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.5)
            radius: 0
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                preventStealing: true
                propagateComposedEvents: false
            }
        }

        // Dialog
        Rectangle {
            id: deviceDialog
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 20
            }
            radius: 0
            color: Theme.surface_container_high
            implicitHeight: deviceDialogContent.implicitHeight

            ColumnLayout {
                id: deviceDialogContent
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    font.pixelSize: 16
                    font.family: Settings.font
                    renderType: Text.NativeRendering
                    antialiasing: false
                    font.hintingPreference: Font.PreferFullHinting
                    color: Theme.on_primary_container
                    text: root.deviceSelectorInput ? "Select input device" : "Select output device"
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.on_primary_container_variant }

                // Device list
                Column {
                    Layout.fillWidth: true
                    spacing: 0

                    Repeater {
                        model: root.showDeviceSelector ? Pipewire.nodes.values.filter(node => {
                            return !node.isStream && node.isSink !== root.deviceSelectorInput && node.audio
                        }) : []

                        Rectangle {
                            required property var modelData
                            width: deviceDialogContent.width
                            height: deviceRow.implicitHeight + 12
                            radius: 0
                            color: deviceHover.hovered ? Theme.surface_container_highest : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }

                            Row {
                                id: deviceRow
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 8
                                    rightMargin: 8
                                }
                                spacing: 10

                                // Radio indicator
                                Rectangle {
                                    width: 14
                                    height: 14
                                    radius: 7
                                    border.width: 2
                                    border.color: isSelected ? Theme.primary : Theme.outline
                                    color: "transparent"
                                    anchors.verticalCenter: parent.verticalCenter

                                    property bool isSelected: root.deviceSelectorInput
                                        ? (modelData.id === Pipewire.defaultAudioSource?.id)
                                        : (modelData.id === Pipewire.defaultAudioSink?.id)

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 6; height: 6; radius: 3
                                        color: Theme.primary
                                        visible: parent.isSelected
                                    }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.description
                                    font.pixelSize: 16
                                    font.family: Settings.font
                                    renderType: Text.NativeRendering
                                    antialiasing: false
                                    font.hintingPreference: Font.PreferFullHinting
                                    color: Theme.on_primary_container
                                    elide: Text.ElideRight
                                    width: parent.width - 14 - 10
                                }
                            }

                            HoverHandler { id: deviceHover }
                            TapHandler {
                                onTapped: root.selectedDevice = modelData
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.on_primary_container_variant }

                // Buttons
                Row {
                    Layout.alignment: Qt.AlignRight
                    spacing: 8

                    Rectangle {
                        height: 30
                        width: cancelTxt.implicitWidth + 20
                        radius: 0
                        color: cancelHover.hovered ? Theme.surface_container_highest : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text {
                            id: cancelTxt
                            anchors.centerIn: parent
                            text: "Cancel"
                            font.pixelSize: 16
                            font.family: Settings.font
                            renderType: Text.NativeRendering
                            antialiasing: false
                            font.hintingPreference: Font.PreferFullHinting
                            color: Theme.primary
                        }
                        HoverHandler { id: cancelHover }
                        TapHandler { onTapped: root.showDeviceSelector = false }
                    }

                    Rectangle {
                        height: 30
                        width: okTxt.implicitWidth + 20
                        radius: 0
                        color: okHover.hovered ? Qt.lighter(Theme.primary, 1.15) : Theme.primary
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text {
                            id: okTxt
                            anchors.centerIn: parent
                            text: "OK"
                            font.pixelSize: 16
                            font.family: Settings.font
                            renderType: Text.NativeRendering
                            antialiasing: false
                            font.hintingPreference: Font.PreferFullHinting
                            color: Theme.on_primary
                        }
                        HoverHandler { id: okHover }
                        TapHandler {
                            onTapped: {
                                root.showDeviceSelector = false
                                if (root.selectedDevice) {
                                    if (root.deviceSelectorInput)
                                        Pipewire.preferredDefaultAudioSource = root.selectedDevice
                                    else
                                        Pipewire.preferredDefaultAudioSink = root.selectedDevice
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
