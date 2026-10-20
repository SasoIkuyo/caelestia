pragma ComponentBehavior: Bound

import "../../../../../Esp.js" as Es
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.I18n
import qs.modules.nexus.common

PageBase {
    id: root

    title: Es.tr(Tr.tr("Tray"))
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        ToggleRow {
            first: true
            text: Es.tr(qsTr("Background"))
            configNode: root.targetConfig.bar.tray
            propertyName: "background"
            checked: root.targetConfig.bar.tray.background
            onToggled: {
                root.targetConfig.bar.tray.background = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Recolour icons"))
            configNode: root.targetConfig.bar.tray
            propertyName: "recolour"
            checked: root.targetConfig.bar.tray.recolour
            onToggled: {
                root.targetConfig.bar.tray.recolour = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Compact"))
            configNode: root.targetConfig.bar.tray
            propertyName: "compact"
            checked: root.targetConfig.bar.tray.compact
            onToggled: {
                root.targetConfig.bar.tray.compact = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            last: true
            text: Es.tr(qsTr("Popout on hover"))
            subtext: Es.tr(qsTr("Show the tray menu popout when hovering"))
            configNode: root.targetConfig.bar.popouts
            propertyName: "tray"
            checked: root.targetConfig.bar.popouts.tray
            onToggled: {
                root.targetConfig.bar.popouts.tray = checked;
                root.targetConfig.save();
            }
        }
    }
}
