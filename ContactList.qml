// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls

import QtCore

import Qt.labs.platform as DialogLabs
//import Qt.labs.settings

ApplicationWindow {
    id: window

    property int currentContact: -1

    width: 800
    height: 600
    visible: true
    title: qsTr("Template App")

    property string currentFileName: qsTr("unknown.txt")
    property string currentDecodedFileName: ""
    property string currentDirectory: "."

    property int iconSize: 40
    property int defaultIconSize: 40
    property int minimalIconSize: 12

    function setFileName(fileUri, decodedFileUri) {
        currentFileName = fileUri
        currentDecodedFileName = decodedFileUri
    }

    function addToOutput(txt) {
        homePage.txtEditor.text += txt + "\n"
    }

    function addErrorMessage(msg) {
        addToOutput(msg)
    }

    function focusToEditor() {
        homePage.txtEditor.forceActiveFocus()
    }

    function processOpenFileCallback(fileName) {
        var content = applicationData.readFileContent(fileName)
        setFileName(fileName, null)
        homePage.txtEditor.text = content
    }

    function processSaveFileCallback(fileName) {
        var content = homePage.txtEditor.text
        setFileName(fileName, null)
        doSaveFile(currentFileName, content, true)
    }

    function doSaveFile(fileName, text, bForceSyncWrite) {
        if( !bForceSyncWrite && applicationData.isWASM && !applicationData.isUseLocalFileDialog )
        {
            applicationData.saveFileContentAsync(text, applicationData.getOnlyFileName(fileName))
        }
        else
        {
            var ok = applicationData.writeFileContent(fileName, text)
            if( !ok )
            {
                var msg= localiseText(qsTr("ERROR: Can not save file ")) + fileName
                addErrorMessage(msg)
            }
        }
    }

    function triggerSaveAsFile() {
        if( !settings.mobileUI )
        {
            fileDialog.openMode = false
            fileDialog.folder = "."
            fileDialog.nameFilters = ["*"]
            fileDialog.open()
        }
        else
        {
            stackView.pop()
            mobileFileDialog.pathsSDCard = applicationData.getSDCardPaths()
            mobileFileDialog.isStorageSupported = applicationData.isAndroid
            mobileFileDialog.isMobilePlatform = applicationData.isAndroid
            mobileFileDialog.isAdminModus = !applicationData.isAndroid
            mobileFileDialog.homePath = applicationData.homePath
            mobileFileDialog.setDirectory(currentDirectory)
            mobileFileDialog.setSaveAsModus(false)
            stackView.push(mobileFileDialog)
            mobileFileDialog.forceActiveFocus()
        }
    }

    function triggerOpenFile() {
/* PATCH
        if( applicationData.isWASM && !applicationData.isUseLocalFileDialog )
        {
            applicationData.getOpenFileContentAsync("*.txt")
        }
        else if( !settings.mobileUI )
        {
            fileDialog.openMode = true
            fileDialog.folder = "."
            fileDialog.nameFilters = ["*"]
            fileDialog.open()
        }
        else
*/
        {
            stackView.pop()
            mobileFileDialog.pathsSDCard = applicationData.getSDCardPaths() // or: ["c:\\tmp","c:\\"]
            mobileFileDialog.isStorageSupported = applicationData.isAndroid
            mobileFileDialog.isMobilePlatform = applicationData.isAndroid
            mobileFileDialog.isAdminModus = !applicationData.isAndroid
            mobileFileDialog.homePath = applicationData.homePath
            mobileFileDialog.setDirectory(currentDirectory)
            mobileFileDialog.setOpenModus()
            stackView.push(mobileFileDialog)
            mobileFileDialog.forceActiveFocus()
        }
    }

    function showSettingsDialog() {
        settingsDialog.chbUseToolBar.checked = settings.useToolBar
        settingsDialog.chbMobileUI.checked = settings.mobileUI
        stackView.push(settingsDialog)
    }

    function showSupportDialog() {
        stackView.push(supportDialog)
    }

    function isDialogOpen() {
        return stackView.currentItem === aboutDialog ||
               stackView.currentItem === mobileFileDialog ||
               stackView.currentItem === settingsDialog
               //|| stackView.currentItem === supportDialog
    }

    function showInfoDialog(msg, title) {
        infoDialog.messageText = msg
        if( title !== undefined ) {
            infoDialog.title = title
        }
        infoDialog.open()
    }

    function showThankYouDialog(supportLevel) {
        showInfoDialog(qsTr("Thank you for supporting the development of this application !"), qsTr("Thank you !"))
    }
/*
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
            text: stackView.currentItem.title
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

    ToolBar {
        id: toolBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        visible: true //settings.useToolBar
        height: settings.useToolBar ? flow.implicitHeight/*implicitHeight*/ : 0
/*
        onHeightChanged: {
            if( toolBar.height>iconSize+flow.spacing ) {
                if( iconSize>minimalIconSize ) {
                    iconSize -= 2
                }
            } else if ( toolBar.height<defaultIconSize ) {
                if( iconSize<defaultIconSize ) {
                    iconSize += 1
                }
            }
        }
*/
        Flow {
            id: flow
            anchors.fill: parent
            spacing: 5

            ToolButton {
                id: toolButtonOpen
                icon.source: "images/open-folder-with-document.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Open"
                onClicked: {
                    triggerOpenFile()
                }
            }
            ToolButton {
                id: toolButtonSave
                icon.source: "images/floppy-disk.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Save"
                onClicked: {
                    triggerSaveAsFile()
                }
            }
            ToolButton {
                id: toolButtonUndo
                icon.source: "images/back-arrow.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Undo"
                onClicked: {
                }
            }
            ToolButton {
                id: toolButtonRedo
                icon.source: "images/redo-arrow.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Redo"
                onClicked: {
                }
            }
            ToolButton {
                id: toolButtonSearch
                icon.source: "images/search.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Search"
                onClicked: {
                }
            }
            ToolButton {
                id: toolButtonReplace
                icon.source: "images/replace.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Replace"
                onClicked: {
                }
            }
            ToolButton {
                id: toolButtonPrevious
                icon.source: "images/left-arrow.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Previous"
                onClicked: {
                }
            }
            ToolButton {
                id: toolButtonNext
                icon.source: "images/right-arrow.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Next"
                onClicked: {
                }
            }
            ToolButton {
                id: toolButtonShare
                icon.source: "images/share.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Share"
                onClicked: {
                    var s = homePage.txtEditor.text
                    applicationData.shareSimpleText(s);
                }
            }
            ToolButton {
                id: toolButtonSettings
                icon.source: "images/settings.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Settings"
                onClicked: {
                    showSettingsDialog()
                }
            }
            ToolButton {
                id: toolButtonClose
                icon.source: "images/close.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Close"
                onClicked: {
                }
            }
        }
    }

    Drawer {
        id: drawer
        width: window.width * 0.66
        height: window.height

        Column {
            anchors.fill: parent

            ItemDelegate {
                text: qsTr("Page 1")
                width: parent.width
                onClicked: {
                    stackView.push("Page1Form.ui.qml")
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Page 2")
                width: parent.width
                onClicked: {
                    stackView.push("Page2Form.ui.qml")
                    drawer.close()
                }
            }
        }
    }

    StackView {
        id: stackView
        initialItem: homePage
        //anchors.fill: parent
        anchors.top: toolBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }

    HomeForm {
        id: homePage
    }

    SettingsDialog {
        id: settingsDialog
        visible: false
    }

    AboutDialog {
        id: aboutDialog
        visible: false
    }

    MobileFileDialog {
        id: mobileFileDialog

        visible: false
    }
/*
    DialogLabs.FileDialog {
        id: fileDialog
        objectName: "fileDialog"
        visible: false
        modality: Qt.ApplicationModal
        //fileMode: openMode ? FileDialog.OpenFile : FileDialog.SaveFile
        title: openMode ? qsTr("Choose a file") : qsTr("Save as")
        folder: "."

        property bool openMode: true

        fileMode: openMode ? DialogLabs.FileDialog.OpenFile : DialogLabs.FileDialog.SaveFile

        //selectExisting: openMode ? true : false
        //selectMultiple: false
        //selectFolder: false
    }

    SupportDialog {
        id: supportDialog
        visible: false
    }

    Dialog {
        id: infoDialog
        visible: false
        title: qsTr("Error")
        width: 300
        height: 200

        property alias messageText: messageId.text

        Flow {
            Label {
                id: messageId
                //text: "hello test !"
            }

            Button {
                text: "Close"

                onClicked: infoDialog.close()
            }
        }

        //standardButtons: StandardButton.Ok
        //buttons: Dialog.MessageDialog.Ok
        onAccepted: {
            console.log("Close error msg")
        }
    }
*/
    Settings {
        id: settings

        property int supportLevel: -1   // no support level at all

        property bool useToolBar: true
        property bool mobileUI: false // applicationData.isMobileUI
    }

    Connections {
        target: mobileFileDialog

        //onRejected: stackView.pop()       // for Qt 5.12.xx
        function onRejected() {
            stackView.pop()
            focusToEditor()
        }
        function onAccepted() {
            currentDirectory = mobileFileDialog.lblDirectoryName.text
            stackView.pop()
            focusToEditor()
        }

        function onSaveSelectedFile(fileName) {
            processSaveFileCallback(fileName)
        }
        function onOpenSelectedFile(fileName) {
            processOpenFileCallback(fileName)
        }
        function onDeleteSelectedFile(fileName) {
            var ok = applicationData.deleteFile(fileName)
            if( !ok ) {
                var msg= localiseText(qsTr("ERROR: Can not delete file ")) + fileName
                addErrorMessage(msg)
            }
        }

        function onStorageOpenFile() {
            //console.log("storage open")
            //addToOutput("storage open")
            storageAccess.openFile()
        }
        function onStorageCreateFile(fileNane) {
            //console.log("storage create file "+fileNane)
            //addToOutput("storage create file "+fileNane)
            setFileName(fileName, null)
            storageAccess.createFile(fileNane)
        }
    }

    Connections {
        target: aboutDialog

        function onClose() {
            stackView.pop()
        }
    }

    Connections {
        target: settingsDialog

        function onAccepted() {
            // TODO: update settings
            settings.useToolBar = settingsDialog.chbUseToolBar.checked
            settings.mobileUI = settingsDialog.chbMobileUI.checked

            stackView.pop()
        }
        function onRejected() {
            stackView.pop()
        }
        function onRestoreDefaultSettings() {
            // TODO: restore default settings
        }
    }

/*
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
*/
}
