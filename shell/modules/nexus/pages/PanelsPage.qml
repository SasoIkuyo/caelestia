import "../../../Esp.js" as Es
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.I18n
import qs.modules.nexus.common

PageBase {
    id: root

    title: Es.tr(Tr.tr("Panels"))

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        NavRow {
            first: true
            icon: "dashboard"
            text: Es.tr(Tr.tr("Dashboard"))
            subtext: Config.dashboard.enabled ? Es.tr(Tr.trCtx("Enabled", "panel status")) : Es.tr(Tr.trCtx("Disabled", "panel status"))
            onClicked: root.nState.openSubPage(1)
        }

        NavRow {
            icon: "dock_to_bottom"
            text: Es.tr(Tr.tr("Taskbar"))
            subtext: Config.bar.persistent ? Es.tr(Tr.tr("Always visible")) : Config.bar.showOnHover ? Es.tr(Tr.tr("Reveal on hover")) : Es.tr(Tr.tr("Reveal on drag"))
            onClicked: root.nState.openSubPage(2)
        }

        NavRow {
            icon: "apps"
            text: Es.tr(Tr.tr("Launcher"))
            subtext: Config.launcher.enabled ? Es.tr(Tr.trCtx("Enabled", "panel status")) : Es.tr(Tr.trCtx("Disabled", "panel status"))
            onClicked: root.nState.openSubPage(3)
        }

        NavRow {
            icon: "dock_to_right"
            text: Es.tr(Tr.tr("Sidebar"))
            subtext: Config.sidebar.enabled ? Es.tr(Tr.trCtx("Enabled", "panel status")) : Es.tr(Tr.trCtx("Disabled", "panel status"))
            onClicked: root.nState.openSubPage(4)
        }

        NavRow {
            last: true
            icon: "construction"
            text: Es.tr(Tr.tr("Utilities"))
            subtext: Config.utilities.enabled ? Es.tr(Tr.trCtx("Enabled", "panel status")) : Es.tr(Tr.trCtx("Disabled", "panel status"))
            onClicked: root.nState.openSubPage(5)
        }
    }
}
