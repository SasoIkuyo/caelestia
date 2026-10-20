pragma ComponentBehavior: Bound

import "../../../../Esp.js" as Es
import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.I18n
import qs.modules.nexus.common

PageBase {
    id: root

    title: Es.tr(Tr.tr("Launcher"))
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        // General
        SectionHeader {
            first: true
            text: Es.tr(Tr.tr("General"))
        }

        ToggleRow {
            first: true
            text: Es.tr(qsTr("Enabled"))
            configNode: root.targetConfig.launcher
            propertyName: "enabled"
            checked: root.targetConfig.launcher.enabled
            onToggled: {
                root.targetConfig.launcher.enabled = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Show on hover"))
            subtext: Es.tr(qsTr("Reveal when the cursor reaches the screen edge"))
            configNode: root.targetConfig.launcher
            propertyName: "showOnHover"
            checked: root.targetConfig.launcher.showOnHover
            onToggled: {
                root.targetConfig.launcher.showOnHover = checked;
                root.targetConfig.save();
            }
        }

        TextFieldRow {
            id: prefixRow

            last: true
            label: Es.tr(qsTr("Action prefix"))
            subtext: Es.tr(qsTr("Prefix used to run actions in the launcher"))
            configNode: root.targetConfig.launcher
            propertyName: "actionPrefix"
            errorText: Es.tr(qsTr("Prefix must not be alphanumeric"))
            value: root.targetConfig.launcher.actionPrefix === ">" ? "" : root.targetConfig.launcher.actionPrefix
            placeholderText: ">"
            maximumLength: 1
            smallField: true
            validate: /^[^a-zA-Z0-9\s]$/
            onEditingFinished: value => {
                if (!field.valid)
                    return;
                root.targetConfig.launcher.actionPrefix = value || ">";
                if (root.targetConfig.launcher.actionPrefix === ">")
                    clear();
                root.targetConfig.save();
            }
        }

        // Display
        SectionHeader {
            text: Es.tr(Tr.tr("Display"))
        }

        StepperRow {
            first: true
            label: Es.tr(qsTr("Max items shown"))
            configNode: root.targetConfig.launcher
            propertyName: "maxShown"
            value: root.targetConfig.launcher.maxShown
            from: 1
            to: 20
            stepSize: 1
            onMoved: v => {
                root.targetConfig.launcher.maxShown = v;
                root.targetConfig.save();
            }
        }

        StepperRow {
            label: Es.tr(qsTr("Max wallpapers"))
            configNode: root.targetConfig.launcher
            propertyName: "maxWallpapers"
            value: root.targetConfig.launcher.maxWallpapers
            from: 1
            to: 30
            stepSize: 1
            onMoved: v => {
                root.targetConfig.launcher.maxWallpapers = v;
                root.targetConfig.save();
            }
        }

        StepperRow {
            last: true
            label: Es.tr(qsTr("Drag threshold"))
            subtext: Es.tr(qsTr("Pixels dragged before the launcher opens"))
            configNode: root.targetConfig.launcher
            propertyName: "dragThreshold"
            value: root.targetConfig.launcher.dragThreshold
            from: 0
            to: 200
            stepSize: 5
            onMoved: v => {
                root.targetConfig.launcher.dragThreshold = v;
                root.targetConfig.save();
            }
        }

        // Behaviour
        SectionHeader {
            text: Es.tr(Tr.tr("Behaviour"))
        }

        ToggleRow {
            first: true
            text: Es.tr(qsTr("Vim keybinds"))
            subtext: Es.tr(qsTr("Navigate results with Ctrl+hjkl"))
            configNode: root.targetConfig.launcher
            propertyName: "vimKeybinds"
            checked: root.targetConfig.launcher.vimKeybinds
            onToggled: {
                root.targetConfig.launcher.vimKeybinds = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            last: true
            text: Es.tr(qsTr("Enable dangerous actions"))
            subtext: Es.tr(qsTr("Allow actions that shut down or log out"))
            configNode: root.targetConfig.launcher
            propertyName: "enableDangerousActions"
            checked: root.targetConfig.launcher.enableDangerousActions
            onToggled: {
                root.targetConfig.launcher.enableDangerousActions = checked;
                root.targetConfig.save();
            }
        }

        // Fuzzy search
        SectionHeader {
            text: Es.tr(Tr.tr("Fuzzy search"))
        }

        ToggleRow {
            first: true
            text: Es.tr(qsTr("Apps"))
            configNode: root.targetConfig.launcher.useFuzzy
            propertyName: "apps"
            checked: root.targetConfig.launcher.useFuzzy.apps
            onToggled: {
                root.targetConfig.launcher.useFuzzy.apps = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Actions"))
            configNode: root.targetConfig.launcher.useFuzzy
            propertyName: "actions"
            checked: root.targetConfig.launcher.useFuzzy.actions
            onToggled: {
                root.targetConfig.launcher.useFuzzy.actions = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Schemes"))
            configNode: root.targetConfig.launcher.useFuzzy
            propertyName: "schemes"
            checked: root.targetConfig.launcher.useFuzzy.schemes
            onToggled: {
                root.targetConfig.launcher.useFuzzy.schemes = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Variants"))
            configNode: root.targetConfig.launcher.useFuzzy
            propertyName: "variants"
            checked: root.targetConfig.launcher.useFuzzy.variants
            onToggled: {
                root.targetConfig.launcher.useFuzzy.variants = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            last: true
            text: Es.tr(qsTr("Wallpapers"))
            configNode: root.targetConfig.launcher.useFuzzy
            propertyName: "wallpapers"
            checked: root.targetConfig.launcher.useFuzzy.wallpapers
            onToggled: {
                root.targetConfig.launcher.useFuzzy.wallpapers = checked;
                root.targetConfig.save();
            }
        }
    }
}
