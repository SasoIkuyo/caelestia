import "../../../Esp.js" as Es
import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: Es.tr(qsTr("Shell Tokens"))

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: TokenConfig.appearance.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: Es.tr(qsTr("General"))
        }

        NavRow {
            first: true
            icon: "grid_view"
            text: Es.tr(qsTr("Rounding & Spacing"))
            subtext: Es.tr(qsTr("Adjust outer margins, paddings, and corner rounding"))
            onClicked: root.nState.openSubPage(1)
        }

        NavRow {
            icon: "format_size"
            text: Es.tr(qsTr("Font Sizes"))
            subtext: Es.tr(qsTr("Set typography scaling for interface text"))
            onClicked: root.nState.openSubPage(2)
        }

        NavRow {
            icon: "space_dashboard"
            text: Es.tr(qsTr("Bar & Dashboard Sizes"))
            subtext: Es.tr(qsTr("Adjust widths of top bar widgets and dashboard tiles"))
            onClicked: root.nState.openSubPage(3)
        }

        NavRow {
            icon: "desktop_windows"
            text: Es.tr(qsTr("Window & Lock Sizes"))
            subtext: Es.tr(qsTr("Modify proportions for main settings window and lock screen"))
            onClicked: root.nState.openSubPage(4)
        }

        NavRow {
            last: true
            icon: "widgets"
            text: Es.tr(qsTr("Shell Element Sizes"))
            subtext: Es.tr(qsTr("Configure launcher grid, notifications, OSD, and sidebars"))
            onClicked: root.nState.openSubPage(5)
        }
    }
}
