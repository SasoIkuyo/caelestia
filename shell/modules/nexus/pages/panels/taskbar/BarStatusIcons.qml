pragma ComponentBehavior: Bound

import "../../../../../Esp.js" as Es
import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    readonly property var builtinIcons: ({
            lockStatus: Es.tr(qsTr("Lock keys")),
            kbLayout: Es.tr(qsTr("Keyboard layout")),
            audio: Es.tr(qsTr("Speakers")),
            microphone: Es.tr(qsTr("Microphone")),
            network: Es.tr(qsTr("Network")),
            bluetooth: Es.tr(qsTr("Bluetooth")),
            battery: Es.tr(qsTr("Battery")),
            peripheralBattery: Es.tr(qsTr("Peripheral battery")),
            notifications: Es.tr(qsTr("Notifications"))
        })

    title: Es.tr(Tr.tr("Status icons"))
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        // Visible icons
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Tokens.padding.small

            StyledText {
                text: Es.tr(qsTr("Visible icons"))
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.label.medium
                elide: Text.ElideRight
            }

            PerMonitorStatusChip {
                configNode: root.targetConfig.bar
                propertyName: "statusIcons"
            }

            Item {
                Layout.fillWidth: true
            }
        }

        ListEditor {
            function labelFor(item: var): string {
                const prettyName = root.builtinIcons[item.id];
                if (prettyName)
                    return prettyName;
                const label = item.id.replace(/([A-Z])/g, " $1");
                return label.charAt(0).toUpperCase() + label.slice(1).toLowerCase();
            }

            function toggledFor(item: var): bool {
                return item.enabled;
            }

            z: 1
            first: true
            values: root.targetConfig.bar.statusIcons.values
            onItemMoved: (from, to) => {
                root.targetConfig.bar.statusIcons.move(from, to);
                root.targetConfig.save();
            }
            onItemRemoved: index => {
                root.targetConfig.bar.statusIcons.remove(index);
                root.targetConfig.save();
            }
            onItemToggled: (index, checked) => {
                root.targetConfig.bar.statusIcons.at(index).enabled = checked;
                root.targetConfig.save();
            }
        }

        DialogSelectButton {
            id: addItemContainer

            rootParent: root.flickable
            icon: "add"
            label: Es.tr(Tr.tr("Add entry"))
            header: Es.tr(Tr.tr("Add new entry"))
            acceptLabel: Es.tr(Tr.trCtx("Add", "button"))

            model: {
                const builtins = Object.keys(root.builtinIcons).map(k => ({
                            id: k,
                            label: root.builtinIcons[k]
                        }));
                return builtins;
            }

            onAccepted: {
                if (!selectedItem) // Should never happen but just in case
                    return;

                root.targetConfig.bar.statusIcons.insert({
                    id: selectedItem,
                    enabled: true
                });
                root.targetConfig.save();
            }
        }

        // Behaviour
        SectionHeader {
            text: Es.tr(Tr.tr("Behaviour"))
        }

        ToggleRow {
            first: true
            last: true
            text: Es.tr(qsTr("Popout on hover"))
            subtext: Es.tr(qsTr("Show a details popout when hovering the status icons"))
            configNode: root.targetConfig.bar.popouts
            propertyName: "statusIcons"
            checked: root.targetConfig.bar.popouts.statusIcons
            onToggled: {
                root.targetConfig.bar.popouts.statusIcons = checked;
                root.targetConfig.save();
            }
        }
    }
}
