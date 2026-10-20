import "../../../../Esp.js" as Es
import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: Es.tr(qsTr("Background elements"))

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        NavRow {
            first: true
            icon: "schedule"
            text: Es.tr(qsTr("Desktop clock"))
            subtext: root.targetConfig.background.desktopClock.enabled ? Es.tr(qsTr("Enabled")) : Es.tr(qsTr("Disabled"))
            onClicked: root.nState.openSubPage(1)
        }

        NavRow {
            icon: "lyrics"
            text: Es.tr(qsTr("Desktop lyrics"))
            subtext: root.targetConfig.background.desktopLyrics.enabled ? Es.tr(qsTr("Enabled")) : Es.tr(qsTr("Disabled"))
            onClicked: root.nState.openSubPage(2)
        }

        NavRow {
            icon: "equalizer"
            text: Es.tr(qsTr("Background visualiser"))
            subtext: root.targetConfig.background.visualiser.enabled ? Es.tr(qsTr("Enabled")) : Es.tr(qsTr("Disabled"))
            onClicked: root.nState.openSubPage(3)
        }

        NavRow {
            last: true
            icon: "pets"
            text: Es.tr(qsTr("Shimeji characters"))
            subtext: root.targetConfig.shimeji.enabled ? Es.tr(qsTr("Enabled")) : Es.tr(qsTr("Disabled"))
            onClicked: root.nState.openSubPage(4)
        }
    }
}
