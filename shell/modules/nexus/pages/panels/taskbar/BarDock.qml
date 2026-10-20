pragma ComponentBehavior: Bound

import "../../../../../Esp.js" as Es
import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: Es.tr(qsTr("Dock"))
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: Es.tr(qsTr("Enable component"))
            checked: {
                const entries = Config.bar.entries;
                for (const section of [entries.start, entries.center, entries.end]) {
                    for (let i = 0; i < section.count; i++) {
                        if (section.at(i).id === "dock")
                            return section.at(i).enabled;
                    }
                }
                return false;
            }
            onToggled: {
                const entries = GlobalConfig.bar.entries;
                for (const section of [entries.start, entries.center, entries.end]) {
                    for (let i = 0; i < section.count; i++) {
                        if (section.at(i).id === "dock") {
                            section.at(i).enabled = checked;
                            GlobalConfig.save();
                            return;
                        }
                    }
                }
                entries.start.insert({
                    id: "dock",
                    enabled: checked
                });
                GlobalConfig.save();
            }
        }

        ToggleRow {
            Layout.fillWidth: true
            text: Es.tr(qsTr("Monitor center"))
            subtext: Es.tr(qsTr("Center the dock relative to the physical monitor"))
            configNode: root.targetConfig.bar.dock
            propertyName: "monitorCenter"
            checked: root.targetConfig.bar.dock.monitorCenter
            onToggled: {
                root.targetConfig.bar.dock.monitorCenter = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: Es.tr(qsTr("Recolour icons"))
            subtext: Es.tr(qsTr("Recolour application icons using the system theme"))
            configNode: root.targetConfig.bar.dock
            propertyName: "recolourIcons"
            checked: root.targetConfig.bar.dock.recolourIcons
            onToggled: {
                root.targetConfig.bar.dock.recolourIcons = checked;
                root.targetConfig.save();
            }
        }
    }
}
