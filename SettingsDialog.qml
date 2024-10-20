import QtQuick
import QtQuick.Controls

SettingsDialogForm {

    signal rejected()
    signal accepted()

    signal restoreDefaultSettings()

    btnCancel {
        onClicked: rejected()
    }

    btnOk {
        onClicked: accepted()
    }

    btnRestoreDefaultSettings {
        onClicked: restoreDefaultSettings()
    }
}
