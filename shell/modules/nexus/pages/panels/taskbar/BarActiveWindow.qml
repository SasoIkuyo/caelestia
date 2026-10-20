pragma ComponentBehavior: Bound

import "../../../../../Esp.js" as Es
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.I18n
import qs.modules.nexus.common

PageBase {
    id: root

    title: Es.tr(Tr.tr("Active window"))
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        ToggleRow {
            first: true
            text: Es.tr(qsTr("Enable component"))
            checked: {
                const entries = Config.bar.entries;
                for (const section of [entries.start, entries.center, entries.end]) {
                    for (let i = 0; i < section.count; i++) {
                        if (section.at(i).id === "activeWindow")
                            return section.at(i).enabled;
                    }
                }
                return false;
            }
            onToggled: {
                const entries = GlobalConfig.bar.entries;
                for (const section of [entries.start, entries.center, entries.end]) {
                    for (let i = 0; i < section.count; i++) {
                        if (section.at(i).id === "activeWindow") {
                            section.at(i).enabled = checked;
                            GlobalConfig.save();
                            return;
                        }
                    }
                }
                entries.center.insert({
                    id: "activeWindow",
                    enabled: checked
                });
                GlobalConfig.save();
            }
        }

        ToggleRow {
            Layout.fillWidth: true
            text: Es.tr(qsTr("Compact"))
            configNode: root.targetConfig.bar.activeWindow
            propertyName: "compact"
            checked: root.targetConfig.bar.activeWindow.compact
            onToggled: {
                root.targetConfig.bar.activeWindow.compact = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Inverted"))
            configNode: root.targetConfig.bar.activeWindow
            propertyName: "inverted"
            checked: root.targetConfig.bar.activeWindow.inverted
            onToggled: {
                root.targetConfig.bar.activeWindow.inverted = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Show on hover"))
            subtext: Es.tr(qsTr("Only show the active window title while hovering"))
            configNode: root.targetConfig.bar.activeWindow
            propertyName: "showOnHover"
            checked: root.targetConfig.bar.activeWindow.showOnHover
            onToggled: {
                root.targetConfig.bar.activeWindow.showOnHover = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            last: true
            text: Es.tr(qsTr("Popout on hover"))
            subtext: Es.tr(qsTr("Show a window details popout when hovering"))
            configNode: root.targetConfig.bar.popouts
            propertyName: "activeWindow"
            checked: root.targetConfig.bar.popouts.activeWindow
            onToggled: {
                root.targetConfig.bar.popouts.activeWindow = checked;
                root.targetConfig.save();
            }
        }
    }
}
