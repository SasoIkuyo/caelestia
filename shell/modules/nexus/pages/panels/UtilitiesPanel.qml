pragma ComponentBehavior: Bound

import "../../../../Esp.js" as Es
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.I18n
import qs.modules.nexus.common

PageBase {
    id: root

    function isToggleOn(id: string): bool {
        const item = Config.utilities.quickToggles.values.find(t => t.id === id);
        return item?.enabled ?? false;
    }

    function setToggleOn(id: string, on: bool): void {
        const list = GlobalConfig.utilities.quickToggles;
        for (let i = 0; i < list.count; i++) {
            const item = list.at(i);
            if (item.id === id) {
                item.enabled = on;
                return;
            }
        }
        list.insert({
            id,
            enabled: on
        });
    }

    title: Es.tr(Tr.tr("Utilities"))
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
            last: true
            text: Es.tr(qsTr("Enabled"))
            subtext: Es.tr(qsTr("Show the utilities panel"))
            configNode: root.targetConfig.utilities
            propertyName: "enabled"
            checked: root.targetConfig.utilities.enabled
            onToggled: {
                root.targetConfig.utilities.enabled = checked;
                root.targetConfig.save();
            }
        }

        // Cards
        SectionHeader {
            text: Es.tr(Tr.tr("Cards"))
        }

        ToggleRow {
            first: true
            text: Es.tr(qsTr("Keep awake"))
            subtext: Es.tr(qsTr("Show the idle inhibitor card"))
            configNode: root.targetConfig.utilities.cards
            propertyName: "keepAwake"
            checked: root.targetConfig.utilities.cards.keepAwake
            onToggled: {
                root.targetConfig.utilities.cards.keepAwake = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Screen recorder"))
            subtext: Es.tr(qsTr("Show the screen recorder card"))
            configNode: root.targetConfig.utilities.cards
            propertyName: "recorder"
            checked: root.targetConfig.utilities.cards.recorder
            onToggled: {
                root.targetConfig.utilities.cards.recorder = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            last: true
            text: Es.tr(qsTr("Quick toggles"))
            subtext: Es.tr(qsTr("Show the quick toggles card"))
            configNode: root.targetConfig.utilities.cards
            propertyName: "quickToggles"
            checked: root.targetConfig.utilities.cards.quickToggles
            onToggled: {
                root.targetConfig.utilities.cards.quickToggles = checked;
                root.targetConfig.save();
            }
        }

        // Quick toggles
        SectionHeader {
            text: Es.tr(Tr.tr("Quick toggles"))
        }

        ToggleRow {
            first: true
            text: Es.tr(Tr.tr("Wi-Fi"))
            subtext: Es.tr(Tr.tr("Toggle wireless networking"))
            disabled: !Config.utilities.cards.quickToggles
            checked: root.isToggleOn("wifi")
            onToggled: root.setToggleOn("wifi", checked)
        }

        ToggleRow {
            text: Es.tr(Tr.tr("Bluetooth"))
            subtext: Es.tr(Tr.tr("Toggle the Bluetooth adapter"))
            disabled: !Config.utilities.cards.quickToggles
            checked: root.isToggleOn("bluetooth")
            onToggled: root.setToggleOn("bluetooth", checked)
        }

        ToggleRow {
            text: Es.tr(Tr.tr("Microphone"))
            subtext: Es.tr(Tr.tr("Mute or unmute the default source"))
            disabled: !Config.utilities.cards.quickToggles
            checked: root.isToggleOn("mic")
            onToggled: root.setToggleOn("mic", checked)
        }

        ToggleRow {
            text: Es.tr(Tr.tr("Settings"))
            subtext: Es.tr(Tr.tr("Open the settings window"))
            disabled: !Config.utilities.cards.quickToggles
            checked: root.isToggleOn("settings")
            onToggled: root.setToggleOn("settings", checked)
        }

        ToggleRow {
            text: Es.tr(Tr.tr("Game mode"))
            subtext: Es.tr(Tr.tr("Toggle game mode"))
            disabled: !Config.utilities.cards.quickToggles
            checked: root.isToggleOn("gameMode")
            onToggled: root.setToggleOn("gameMode", checked)
        }

        ToggleRow {
            text: Es.tr(Tr.tr("Do not disturb"))
            subtext: Es.tr(Tr.tr("Silence notifications"))
            disabled: !Config.utilities.cards.quickToggles
            checked: root.isToggleOn("dnd")
            onToggled: root.setToggleOn("dnd", checked)
        }

        ToggleRow {
            last: true
            text: Es.tr(Tr.tr("VPN"))
            subtext: Es.tr(Tr.tr("Connect or disconnect the VPN"))
            disabled: !Config.utilities.cards.quickToggles
            checked: root.isToggleOn("vpn")
            onToggled: root.setToggleOn("vpn", checked)
        }

        ToggleRow {
            text: Es.tr(qsTr("Quick Share"))
            subtext: Es.tr(qsTr("Send and receive files nearby"))
            disabled: !Config.utilities.cards.quickToggles
            checked: root.isToggleOn("quickshare")
            onToggled: root.setToggleOn("quickshare", checked)
        }

        ToggleRow {
            text: Es.tr(qsTr("Wallpaper selector"))
            subtext: Es.tr(qsTr("Show the wallpaper picker menu"))
            disabled: !Config.utilities.cards.quickToggles
            checked: root.isToggleOn("wallpaper")
            onToggled: root.setToggleOn("wallpaper", checked)
        }

        ToggleRow {
            text: Es.tr(qsTr("Bad Apple"))
            subtext: Es.tr(qsTr("Play the Bad Apple animation"))
            disabled: !Config.utilities.cards.quickToggles
            checked: root.isToggleOn("badapple")
            onToggled: root.setToggleOn("badapple", checked)
        }

        ToggleRow {
            text: Es.tr(qsTr("Pause video wallpaper"))
            subtext: Es.tr(qsTr("Pause or resume the video wallpaper"))
            disabled: !Config.utilities.cards.quickToggles
            checked: root.isToggleOn("pauseWallpaper")
            onToggled: root.setToggleOn("pauseWallpaper", checked)
        }

        ToggleRow {
            last: true
            text: Es.tr(qsTr("Pause PiP"))
            subtext: Es.tr(qsTr("Pause or resume picture-in-picture"))
            disabled: !Config.utilities.cards.quickToggles
            checked: root.isToggleOn("pipPause")
            onToggled: root.setToggleOn("pipPause", checked)
        }
    }
}
