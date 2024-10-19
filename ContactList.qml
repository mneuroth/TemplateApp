// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: window

    property int currentContact: -1

    width: 320
    height: 480
    visible: true
    title: qsTr("Contact List")

    ContactDialog {
        id: contactDialog
        onFinished: function(fullName, address, city, number) {
            if (window.currentContact === -1)
                contactView.model.append(fullName, address, city, number)
            else
                contactView.model.set(window.currentContact, fullName, address, city, number)
        }
    }

    Menu {
        id: contactMenu
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
        modal: true

        Label {
            padding: 10
            font.bold: true
            width: parent.width
            horizontalAlignment: Qt.AlignHCenter
            text: window.currentContact >= 0 ? contactView.model.get(window.currentContact).fullName : ""
        }
        MenuItem {
            text: qsTr("Edit...")
            onTriggered: contactDialog.editContact(contactView.model.get(window.currentContact))
        }
        MenuItem {
            text: qsTr("Remove")
            onTriggered: contactView.model.remove(window.currentContact)
        }
    }
/*
    ContactView {
        id: contactView
        anchors.fill: parent
        onPressAndHold: function(index) {
            window.currentContact = index
            contactMenu.open()
        }
    }
*/
    header: ToolBar {
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            //text: stackView.depth > 1 ? "\u25C0" : "\u2630"
            //xxxicon.source: stackView.depth > 1 ? "images/back.svg" : "images/menu_bars.svg"
            icon.source: "images/menu_bars.svg"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            anchors.left: parent.left
            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
        }

        Label {
            text: "stackView.currentItem.title"//xxx
            anchors.centerIn: parent
        }

        ToolButton {
            id: menuButton
            //text: "\u22EE"
            //xxxenabled: !isDialogOpen()
            icon.source: "images/menu.svg"
            font.pixelSize: Qt.application.font.pixelSize * 2.0
            anchors.right: parent.right
            onClicked: menu.open()

            Menu {
                id: menu
                //xxxenabled: !isDialogOpen()
                y: menuButton.height

                MenuItem {
                    text: qsTr("Open")
                    //icon.source: "images/open.svg"
                    //xxxenabled: !isDialogOpen()
                    onTriggered: {
                        triggerOpenFile()
                    }
                }
                MenuItem {
                    text: qsTr("Save")
                    //icon.source: "images/save.svg"
                    //xxxenabled: !isDialogOpen()
                    onTriggered: {
                        doSaveFile(currentFileName, homePage.txtEditor.text)
                    }
                }
                MenuItem {
                    text: qsTr("Save as")
                    //icon.source: "images/saveas.svg"
                    //xxxenabled: !isDialogOpen()
                    onTriggered: {
                        triggerSaveAsFile()
                    }
                }
                MenuItem {
                    text: qsTr("Delete")
                    //icon.source: "images/delete.svg"
                    //xxxenabled: !isDialogOpen()
                    onTriggered: {
                        stackView.pop()
                        mobileFileDialog.pathsSDCard = applicationData.getSDCardPaths()
                        mobileFileDialog.isStorageSupported = applicationData.isAndroid
                        mobileFileDialog.isMobilePlatform = applicationData.isAndroid
                        mobileFileDialog.isAdminModus = !applicationData.isAndroid
                        mobileFileDialog.homePath = applicationData.homePath
                        mobileFileDialog.setDirectory(currentDirectory)
                        mobileFileDialog.setDeleteModus()
                        stackView.push(mobileFileDialog)
                        mobileFileDialog.forceActiveFocus()
                    }
                }
                MenuSeparator {}
                MenuItem {
                    text: qsTr("Support")
                    //xxxenabled: !isDialogOpen()
                    onTriggered: {
                        showSupportDialog()
                    }
                }
                MenuSeparator {}
                MenuItem {
                    text: qsTr("Settings")
                    //xxxenabled: !isDialogOpen()
                    onTriggered: {
                        showSettingsDialog()
                    }
                }
                MenuSeparator {}
                MenuItem {
                    text: qsTr("About")
                    //xxxenabled: !isDialogOpen()
                    onTriggered: {
                        stackView.push(aboutDialog)
                    }
                }
                MenuSeparator {}
                MenuItem {
                    text: qsTr("Exit")
                    onTriggered: {
                        Qt.quit()
                    }
                }
            }
        }
    }

    RoundButton {
        text: qsTr("+")
        highlighted: true
        anchors.margins: 10
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        onClicked: {
            window.currentContact = -1
            contactDialog.createContact()
        }
    }
}
