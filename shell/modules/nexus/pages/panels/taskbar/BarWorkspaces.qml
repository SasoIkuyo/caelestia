pragma ComponentBehavior: Bound

import "../../../../../Esp.js" as Es
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.I18n
import qs.modules.nexus.common

PageBase {
    id: root

    title: Es.tr(Tr.tr("Workspaces"))
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        StepperRow {
            first: true
            label: Es.tr(qsTr("Shown"))
            subtext: Es.tr(qsTr("Number of workspaces displayed"))
            configNode: root.targetConfig.bar.workspaces
            propertyName: "shown"
            value: root.targetConfig.bar.workspaces.shown
            from: 1
            to: 20
            stepSize: 1
            onMoved: v => {
                root.targetConfig.bar.workspaces.shown = v;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Active indicator"))
            configNode: root.targetConfig.bar.workspaces
            propertyName: "activeIndicator"
            checked: root.targetConfig.bar.workspaces.activeIndicator
            onToggled: {
                root.targetConfig.bar.workspaces.activeIndicator = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Active trail"))
            configNode: root.targetConfig.bar.workspaces
            propertyName: "activeTrail"
            checked: root.targetConfig.bar.workspaces.activeTrail
            onToggled: {
                root.targetConfig.bar.workspaces.activeTrail = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Occupied background"))
            configNode: root.targetConfig.bar.workspaces
            propertyName: "occupiedBg"
            checked: root.targetConfig.bar.workspaces.occupiedBg
            onToggled: {
                root.targetConfig.bar.workspaces.occupiedBg = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            Layout.fillWidth: true
            text: Es.tr(qsTr("Use material icons for indicators"))
            configNode: root.targetConfig.bar.workspaces
            propertyName: "useIcon"
            checked: root.targetConfig.bar.workspaces.useIcon
            onToggled: {
                root.targetConfig.bar.workspaces.useIcon = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Show windows"))
            subtext: Es.tr(qsTr("Show icons of open windows on each workspace"))
            configNode: root.targetConfig.bar.workspaces
            propertyName: "showWindows"
            checked: root.targetConfig.bar.workspaces.showWindows
            onToggled: {
                root.targetConfig.bar.workspaces.showWindows = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Show unoccupied"))
            subtext: Es.tr(qsTr("Show workspaces that are inactive and empty"))
            configNode: root.targetConfig.bar.workspaces
            propertyName: "showUnoccupied"
            checked: root.targetConfig.bar.workspaces.showUnoccupied
            onToggled: {
                root.targetConfig.bar.workspaces.showUnoccupied = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            last: true
            text: Es.tr(qsTr("Windows on special workspaces"))
            configNode: root.targetConfig.bar.workspaces
            propertyName: "showWindowsOnSpecialWorkspaces"
            checked: root.targetConfig.bar.workspaces.showWindowsOnSpecialWorkspaces
            onToggled: {
                root.targetConfig.bar.workspaces.showWindowsOnSpecialWorkspaces = checked;
                root.targetConfig.save();
            }
        }

        StepperRow {
            label: Es.tr(qsTr("Max window icons"))
            subtext: Es.tr(qsTr("Maximum number of window icons shown per workspace"))
            configNode: root.targetConfig.bar.workspaces
            propertyName: "maxWindowIcons"
            value: root.targetConfig.bar.workspaces.maxWindowIcons
            from: 0
            to: 20
            stepSize: 1
            onMoved: v => {
                root.targetConfig.bar.workspaces.maxWindowIcons = v;
                root.targetConfig.save();
            }
        }
    }
}
