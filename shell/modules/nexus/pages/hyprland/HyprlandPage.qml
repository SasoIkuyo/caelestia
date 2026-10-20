import "../../../../Esp.js" as Es
import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: Es.tr(qsTr("Hyprland"))

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2



        NavRow {
            first: true
            icon: "data_object"
            text: Es.tr(qsTr("Variables"))
            subtext: Es.tr(qsTr("Manage your hyprland variables"))
            onClicked: root.nState.openSubPage(1)
        }

        NavRow {
            icon: "keyboard"
            text: Es.tr(qsTr("Keybinds"))
            subtext: Es.tr(qsTr("Manage your hyprland keybinds"))
            onClicked: root.nState.openSubPage(2)
        }

        NavRow {
            last: true
            icon: "settings_suggest"
            text: Es.tr(qsTr("User configuration"))
            subtext: Es.tr(qsTr("Advanced configuration options"))
            onClicked: root.nState.openSubPage(3)
        }
    }
}
