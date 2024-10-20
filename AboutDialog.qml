import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls

AboutDialogForm {

    signal close()

    lblAppInfos {
        text: "???" //applicationData !== null ? applicationData.getAppInfos() : "?"
    }

    lblIconInfos {
        onLinkActivated: Qt.openUrlExternally(link)
    }

    lblAppName {
        onLinkActivated: Qt.openUrlExternally(link)
    }

    lblGithubPage {
        onLinkActivated: Qt.openUrlExternally(link)
    }

    btnClose {
        onClicked: close()
    }
}
