import qs
import qs.services
import qs.utils
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    required property var wifiNetwork
    property bool askingPassword: false

    height: contentCol.implicitHeight + 16
    Behavior on height {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        anchors.fill: parent
        color: itemHover.hovered && !root.askingPassword ? Theme.surface_container_highest : "transparent"
        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }

    ColumnLayout {
        id: contentCol
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 16
            rightMargin: 16
        }
        spacing: 0

        // ── Network row ────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Signal strength icon
            Text {
                property int s: root.wifiNetwork?.strength ?? 0
                text: s > 80 ? "󰤨" : s > 60 ? "󰤥" : s > 40 ? "󰤢" : s > 20 ? "󰤟" : "󰤯"
                font.pixelSize: 16
                font.family: Settings.iconFont
                renderType: Text.NativeRendering
                antialiasing: false
                font.hintingPreference: Font.PreferFullHinting
                color: Theme.on_surface_variant
            }

            // SSID
            Text {
                Layout.fillWidth: true
                text: root.wifiNetwork?.ssid ?? "Unknown"
                font.pixelSize: 16
                font.family: Settings.font
                renderType: Text.NativeRendering
                antialiasing: false
                font.hintingPreference: Font.PreferFullHinting
                color: Theme.on_surface_variant
                elide: Text.ElideRight
            }

            // Status icon
            Text {
                text: root.wifiNetwork?.active ? "" : root.wifiNetwork?.isSecure ? "" : ""
                visible: root.wifiNetwork?.active || root.wifiNetwork?.isSecure
                font.pixelSize: 16
                font.family: Settings.iconFont
                renderType: Text.NativeRendering
                antialiasing: false
                font.hintingPreference: Font.PreferFullHinting
                color: root.wifiNetwork?.active ? Theme.primary : Theme.outline
            }
        }

        // ── Password prompt (shown when needs password) ────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            visible: root.askingPassword
            opacity: root.askingPassword ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            TextField {
                id: passwordField
                Layout.fillWidth: true
                placeholderText: "Password"
                echoMode: TextInput.Password
                font.pixelSize: 16
                font.family: Settings.font
                background: Rectangle {
                    color: Theme.surface_container
                    border.width: passwordField.activeFocus ? 1 : 0
                    border.color: Theme.primary
                    radius: 0
                }
                color: Theme.on_surface_variant

                onAccepted: {
                    NetworkConnection.connectWithPassword(root.wifiNetwork, passwordField.text, null);
                    root.askingPassword = false;
                    passwordField.clear();
                }
            }

            Row {
                Layout.fillWidth: true
                layoutDirection: Qt.RightToLeft
                spacing: 8

                Rectangle {
                    height: 28
                    width: connectTxt2.implicitWidth + 20
                    radius: 0
                    color: connectHover2.hovered ? Qt.lighter(Theme.primary, 1.15) : Theme.primary
                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }
                    Text {
                        id: connectTxt2
                        anchors.centerIn: parent
                        text: "Connect"
                        font.pixelSize: 16
                        font.family: Settings.font
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: Theme.on_primary
                    }
                    HoverHandler {
                        id: connectHover2
                    }
                    TapHandler {
                        onTapped: {
                            NetworkConnection.connectWithPassword(root.wifiNetwork, passwordField.text, null);
                            root.askingPassword = false;
                            passwordField.clear();
                        }
                    }
                }

                Rectangle {
                    height: 28
                    width: cancelTxt2.implicitWidth + 20
                    radius: 0
                    color: cancelHover2.hovered ? Theme.surface_container_highest : "transparent"
                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }
                    Text {
                        id: cancelTxt2
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.pixelSize: 16
                        font.family: Settings.font
                        renderType: Text.NativeRendering
                        antialiasing: false
                        font.hintingPreference: Font.PreferFullHinting
                        color: Theme.primary
                    }
                    HoverHandler {
                        id: cancelHover2
                    }
                    TapHandler {
                        onTapped: {
                            root.askingPassword = false;
                            passwordField.clear();
                        }
                    }
                }
            }
        }
    }

    // Click to connect (only when not showing password)
    TapHandler {
        enabled: !root.askingPassword
        onTapped: {
            NetworkConnection.handleConnect(root.wifiNetwork, net => {
                root.askingPassword = true;
                passwordField.forceActiveFocus();
            });
        }
    }

    HoverHandler {
        id: itemHover
    }
}
