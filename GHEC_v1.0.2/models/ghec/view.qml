import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Dialogs as Dialogs
import NControls as NControls
import Themes

import "../CommonQmlItems"

Dialogs.DialogBase {
    id: root
    property var controller: model

    contentItem: Item {
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20 // Keep comfortable spacing from the dialog edges.
            spacing: 12 // Keep section spacing visually consistent.

            RowLayout {
                Layout.fillWidth: true

                NControls.Text {
                    text: "G-HUB"
                    font.pixelSize: 20
                    font.bold: true
                    color: Theme.colors.text
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    implicitWidth: 12
                    implicitHeight: 12
                    radius: 6
                    color: {
                        if (model.status_code === "connected") return "#43d17a"
                        if (model.status_code === "connecting") return "#d8b64c"
                        if (model.status_code === "error") return "#e05656"
                        return "#707070"
                    }
                }

                NControls.Text {
                    text: model.status_text
                    font.pixelSize: 12
                    color: Theme.colors.text
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: "#505050"
            }

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 2
                    NControls.Text {
                        text: "CONTROL"
                        font.pixelSize: 10
                        color: "#888888"
                    }
                    RowLayout {
                        spacing: 5

                        NControls.Text {
                            text: "127.0.0.1 :"
                            font.pixelSize: 13
                            color: Theme.colors.text
                        }

                        TextField {
                            id: controlPortField
                            implicitWidth: 72
                            implicitHeight: 26
                            text: model.control_port.toString()
                            enabled: model.control_port_editable
                            selectByMouse: true
                            horizontalAlignment: TextInput.AlignHCenter
                            color: enabled ? Theme.colors.text : "#777777"
                            font.pixelSize: 12
                            inputMethodHints: Qt.ImhDigitsOnly
                            validator: IntValidator { bottom: 1; top: 65535 }

                            background: Rectangle {
                                color: controlPortField.enabled ? "#242424" : "#1b1b1b"
                                border.color: controlPortField.activeFocus ? "#4f91bd" : "#505050"
                                border.width: 1
                                radius: 2
                            }

                            onEditingFinished: {
                                if (!acceptableInput
                                        || !model.set_control_port(parseInt(text))) {
                                    text = model.control_port.toString()
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Dialogs.DialogButton {
                    text: model.connected ? "DISCONNECT" : "CONNECT"
                    onClicked: model.toggle_connection()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: "#3f3f3f"
            }

            RowLayout {
                Layout.fillWidth: true

                NControls.Text {
                    text: "ENDPOINT"
                    font.pixelSize: 10
                    color: "#888888"
                }

                Item { Layout.fillWidth: true }

                NControls.Text {
                    text: model.connected ? "EP_" + model.endpoint_id : "-"
                    font.pixelSize: 12
                    color: Theme.colors.text
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: "#3f3f3f"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    NControls.Text {
                        text: "CHARACTER SLOTS"
                        font.pixelSize: 10
                        color: "#888888"
                    }

                    Item { Layout.fillWidth: true }

                    Dialogs.DialogButton {
                        text: model.slot_configuration_dirty ? "SAVE*" : "SAVE"
                        enabled: model.slot_configuration_editable
                                 && model.slot_configuration_dirty
                        Layout.preferredWidth: 82
                        Layout.leftMargin: 10
                        onClicked: model.save_character_slots()
                    }

                    Dialogs.DialogButton {
                        text: "REFRESH"
                        enabled: model.slot_configuration_editable
                        Layout.preferredWidth: 96
                        Layout.leftMargin: 4
                        Layout.rightMargin: 2
                        onClicked: model.refresh_character_candidates()
                    }
                }

                NControls.Text {
                    text: "Choose the Cascadeur Character branch owned by each URSS Slot."
                    font.pixelSize: 9
                    color: "#777777"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                NControls.Text {
                    text: model.slot_configuration_dirty
                          ? "Unsaved Slot changes. Press SAVE, then save the .cas scene."
                          : "SAVE stores Slot assignments in the scene; normal .cas save keeps them after restart."
                    font.pixelSize: 9
                    color: model.slot_configuration_dirty ? "#d8b64c" : "#666666"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 7

                        NControls.Text {
                            text: "Character 1"
                            font.pixelSize: 11
                            color: Theme.colors.text
                            Layout.preferredWidth: 68
                        }

                        ComboBox {
                            id: character1Combo
                            Layout.fillWidth: true
                            implicitHeight: 28
                            enabled: root.controller.slot_configuration_editable
                            model: root.controller.character_candidate_labels
                            currentIndex: root.controller.character1_candidate_index
                            palette.button: "#252525"
                            palette.buttonText: Theme.colors.text
                            palette.text: Theme.colors.text
                            palette.base: "#252525"
                            palette.window: "#202020"
                            palette.windowText: Theme.colors.text
                            palette.highlight: "#34566b"
                            palette.highlightedText: Theme.colors.text
                            onActivated: root.controller.set_character_candidate(0, currentIndex)
                        }

                        NControls.Text {
                            text: "char_01"
                            font.pixelSize: 9
                            color: "#858585"
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: 42
                        }

                        NControls.CheckBox {
                            type: NControls.CheckBox.Radio
                            profile: NControls.CheckBox.Small
                            enabled: model.slot_configuration_editable
                            checked: model.character1_enabled
                            onToggled: model.set_character1_enabled(checked)
                        }
                    }

                    NControls.Text {
                        text: model.character1_assignment_text
                        font.pixelSize: 9
                        color: text.indexOf("Explicit") === 0 ? "#43d17a" : "#777777"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        Layout.leftMargin: 75
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 7

                        NControls.Text {
                            text: "Character 2"
                            font.pixelSize: 11
                            color: Theme.colors.text
                            Layout.preferredWidth: 68
                        }

                        ComboBox {
                            id: character2Combo
                            Layout.fillWidth: true
                            implicitHeight: 28
                            enabled: root.controller.slot_configuration_editable
                            model: root.controller.character_candidate_labels
                            currentIndex: root.controller.character2_candidate_index
                            palette.button: "#252525"
                            palette.buttonText: Theme.colors.text
                            palette.text: Theme.colors.text
                            palette.base: "#252525"
                            palette.window: "#202020"
                            palette.windowText: Theme.colors.text
                            palette.highlight: "#34566b"
                            palette.highlightedText: Theme.colors.text
                            onActivated: root.controller.set_character_candidate(1, currentIndex)
                        }

                        NControls.Text {
                            text: "char_02"
                            font.pixelSize: 9
                            color: "#858585"
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: 42
                        }

                        NControls.CheckBox {
                            type: NControls.CheckBox.Radio
                            profile: NControls.CheckBox.Small
                            enabled: model.slot_configuration_editable
                            checked: model.character2_enabled
                            onToggled: model.set_character2_enabled(checked)
                        }
                    }

                    NControls.Text {
                        text: model.character2_assignment_text
                        font.pixelSize: 9
                        color: text.indexOf("Explicit") === 0 ? "#43d17a" : "#777777"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        Layout.leftMargin: 75
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 7

                        NControls.Text {
                            text: "Character 3"
                            font.pixelSize: 11
                            color: Theme.colors.text
                            Layout.preferredWidth: 68
                        }

                        ComboBox {
                            id: character3Combo
                            Layout.fillWidth: true
                            implicitHeight: 28
                            enabled: root.controller.slot_configuration_editable
                            model: root.controller.character_candidate_labels
                            currentIndex: root.controller.character3_candidate_index
                            palette.button: "#252525"
                            palette.buttonText: Theme.colors.text
                            palette.text: Theme.colors.text
                            palette.base: "#252525"
                            palette.window: "#202020"
                            palette.windowText: Theme.colors.text
                            palette.highlight: "#34566b"
                            palette.highlightedText: Theme.colors.text
                            onActivated: root.controller.set_character_candidate(2, currentIndex)
                        }

                        NControls.Text {
                            text: "char_03"
                            font.pixelSize: 9
                            color: "#858585"
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: 42
                        }

                        NControls.CheckBox {
                            type: NControls.CheckBox.Radio
                            profile: NControls.CheckBox.Small
                            enabled: model.slot_configuration_editable
                            checked: model.character3_enabled
                            onToggled: model.set_character3_enabled(checked)
                        }
                    }

                    NControls.Text {
                        text: model.character3_assignment_text
                        font.pixelSize: 9
                        color: text.indexOf("Explicit") === 0 ? "#43d17a" : "#777777"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        Layout.leftMargin: 75
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 7

                        NControls.Text {
                            text: "Character 4"
                            font.pixelSize: 11
                            color: Theme.colors.text
                            Layout.preferredWidth: 68
                        }

                        ComboBox {
                            id: character4Combo
                            Layout.fillWidth: true
                            implicitHeight: 28
                            enabled: root.controller.slot_configuration_editable
                            model: root.controller.character_candidate_labels
                            currentIndex: root.controller.character4_candidate_index
                            palette.button: "#252525"
                            palette.buttonText: Theme.colors.text
                            palette.text: Theme.colors.text
                            palette.base: "#252525"
                            palette.window: "#202020"
                            palette.windowText: Theme.colors.text
                            palette.highlight: "#34566b"
                            palette.highlightedText: Theme.colors.text
                            onActivated: root.controller.set_character_candidate(3, currentIndex)
                        }

                        NControls.Text {
                            text: "char_04"
                            font.pixelSize: 9
                            color: "#858585"
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: 42
                        }

                        NControls.CheckBox {
                            type: NControls.CheckBox.Radio
                            profile: NControls.CheckBox.Small
                            enabled: model.slot_configuration_editable
                            checked: model.character4_enabled
                            onToggled: model.set_character4_enabled(checked)
                        }
                    }

                    NControls.Text {
                        text: model.character4_assignment_text
                        font.pixelSize: 9
                        color: text.indexOf("Explicit") === 0 ? "#43d17a" : "#777777"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        Layout.leftMargin: 75
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 7

                        NControls.Text {
                            text: "Character 5"
                            font.pixelSize: 11
                            color: Theme.colors.text
                            Layout.preferredWidth: 68
                        }

                        ComboBox {
                            id: character5Combo
                            Layout.fillWidth: true
                            implicitHeight: 28
                            enabled: root.controller.slot_configuration_editable
                            model: root.controller.character_candidate_labels
                            currentIndex: root.controller.character5_candidate_index
                            palette.button: "#252525"
                            palette.buttonText: Theme.colors.text
                            palette.text: Theme.colors.text
                            palette.base: "#252525"
                            palette.window: "#202020"
                            palette.windowText: Theme.colors.text
                            palette.highlight: "#34566b"
                            palette.highlightedText: Theme.colors.text
                            onActivated: root.controller.set_character_candidate(4, currentIndex)
                        }

                        NControls.Text {
                            text: "char_05"
                            font.pixelSize: 9
                            color: "#858585"
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: 42
                        }

                        NControls.CheckBox {
                            type: NControls.CheckBox.Radio
                            profile: NControls.CheckBox.Small
                            enabled: model.slot_configuration_editable
                            checked: model.character5_enabled
                            onToggled: model.set_character5_enabled(checked)
                        }
                    }

                    NControls.Text {
                        text: model.character5_assignment_text
                        font.pixelSize: 9
                        color: text.indexOf("Explicit") === 0 ? "#43d17a" : "#777777"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        Layout.leftMargin: 75
                    }
                }

                NControls.Text {
                    text: model.slot_configuration_editable
                          ? "Legacy fallback is kept only for pre-v1.0.2 compatibility. REFRESH rescans Character root Joint branches."
                          : "Disconnect to change Character Slots."
                    font.pixelSize: 9
                    color: "#777777"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: "#3f3f3f"
            }

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 2

                    NControls.Text {
                        text: "TIMELINE SYNC"
                        font.pixelSize: 10
                        color: "#888888"
                    }

                    NControls.Text {
                        text: model.timeline_sync_enabled ? "ON" : "OFF"
                        font.pixelSize: 12
                        color: Theme.colors.text
                    }
                }

                Item { Layout.fillWidth: true }

                NControls.CheckBox {
                    type: NControls.CheckBox.Radio
                    profile: NControls.CheckBox.Small
                    checked: model.timeline_sync_enabled
                    onToggled: model.set_timeline_sync_enabled(checked)
                }
            }

            Item { Layout.fillHeight: true } // Keep the Close row anchored near the bottom.

            RowLayout {
                Layout.fillWidth: true

                NControls.Text {
                    text: model.connected ? "Closing this panel keeps GHEC connected." : ""
                    font.pixelSize: 10
                    color: "#888888"
                }

                Item { Layout.fillWidth: true }

                Dialogs.DialogButton {
                    text: "CLOSE"
                    Layout.bottomMargin: 10
                    onClicked: root.window.close()
                }
            }
        }
    }

    Component.onCompleted: {
        root.implicitWidth = 470
        root.implicitHeight = 700
    }
}
