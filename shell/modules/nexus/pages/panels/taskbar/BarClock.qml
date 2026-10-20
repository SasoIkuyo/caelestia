pragma ComponentBehavior: Bound

import "../../../../../Esp.js" as Es
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.I18n
import qs.modules.nexus.common

PageBase {
    id: root

    title: Es.tr(Tr.tr("Clock"))
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        ToggleRow {
            first: true
            text: Es.tr(qsTr("Background"))
            configNode: root.targetConfig.bar.clock
            propertyName: "background"
            checked: root.targetConfig.bar.clock.background
            onToggled: {
                root.targetConfig.bar.clock.background = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Show date"))
            configNode: root.targetConfig.bar.clock
            propertyName: "showDate"
            checked: root.targetConfig.bar.clock.showDate
            onToggled: {
                root.targetConfig.bar.clock.showDate = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Show icon"))
            configNode: root.targetConfig.bar.clock
            propertyName: "showIcon"
            checked: root.targetConfig.bar.clock.showIcon
            onToggled: {
                root.targetConfig.bar.clock.showIcon = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            last: true
            text: Es.tr(qsTr("Show seconds"))
            configNode: root.targetConfig.bar.clock
            propertyName: "showSeconds"
            checked: root.targetConfig.bar.clock.showSeconds
            onToggled: {
                root.targetConfig.bar.clock.showSeconds = checked;
                root.targetConfig.save();
            }
        }
    }
}
