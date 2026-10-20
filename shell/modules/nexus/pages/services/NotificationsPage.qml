import "../../../../Esp.js" as Es
import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.I18n
import qs.components.controls
import qs.modules.nexus.common

PageBase {
    id: root

    // Notification fullscreen visibility, ordered to match config::NotifsFullscreen (On, Off)
    readonly property list<MenuItem> notifFullscreenItems: [
        MenuItem {
            text: Es.tr(Tr.trCtx("On", "show notifications over fullscreen apps"))
            icon: "notifications"
        },
        MenuItem {
            text: Es.tr(Tr.trCtx("Off", "show notifications over fullscreen apps"))
            icon: "notifications_off"
        }
    ]

    // Toast fullscreen visibility, mapped to GlobalConfig.utilities.toasts.fullscreen
    readonly property list<MenuItem> toastFullscreenItems: [
        MenuItem {
            text: Es.tr(Tr.trCtx("Off", "show toasts over fullscreen apps"))
            icon: "notifications_off"
        },
        MenuItem {
            text: Es.tr(Tr.trCtx("Important", "show toasts over fullscreen apps: important ones only"))
            icon: "priority_high"
        },
        MenuItem {
            text: Es.tr(Tr.trCtx("On", "show toasts over fullscreen apps"))
            icon: "notifications"
        }
    ]
    readonly property list<string> toastFullscreenValues: ["off", "important", "all"]

    title: Es.tr(Tr.tr("Notifications"))
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        // Notifications
        SectionHeader {
            first: true
            text: Es.tr(Tr.tr("Notifications"))
        }

        SelectRow {
            first: true
            label: Es.tr(qsTr("Show in fullscreen"))
            subtext: Es.tr(qsTr("Whether notifications appear over fullscreen apps"))
            configNode: root.targetConfig.notifs
            propertyName: "fullscreen"
            menuItems: root.notifFullscreenItems
            active: root.notifFullscreenItems[Math.max(0, root.notifFullscreenValues.indexOf(root.targetConfig.notifs.fullscreen))]
            onSelected: item => {
                root.targetConfig.notifs.fullscreen = root.notifFullscreenValues[root.notifFullscreenItems.indexOf(item)];
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Expire automatically"))
            subtext: Es.tr(qsTr("Dismiss notifications after their timeout"))
            configNode: root.targetConfig.notifs
            propertyName: "expire"
            checked: root.targetConfig.notifs.expire
            onToggled: {
                root.targetConfig.notifs.expire = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Open expanded"))
            subtext: Es.tr(qsTr("Show notifications expanded by default"))
            configNode: root.targetConfig.notifs
            propertyName: "openExpanded"
            checked: root.targetConfig.notifs.openExpanded
            onToggled: {
                root.targetConfig.notifs.openExpanded = checked;
                root.targetConfig.save();
            }
        }

        StepperRow {
            label: Es.tr(qsTr("Default timeout"))
            subtext: Es.tr(qsTr("Time before a notification dismisses (ms)"))
            configNode: root.targetConfig.notifs
            propertyName: "defaultExpireTimeout"
            value: root.targetConfig.notifs.defaultExpireTimeout
            from: 1000
            to: 60000
            stepSize: 500
            onMoved: v => {
                root.targetConfig.notifs.defaultExpireTimeout = Math.round(v);
                root.targetConfig.save();
            }
        }

        StepperRow {
            last: true
            label: Es.tr(qsTr("Group preview count"))
            subtext: Es.tr(qsTr("Notifications shown per group before collapsing"))
            configNode: root.targetConfig.notifs
            propertyName: "groupPreviewNum"
            value: root.targetConfig.notifs.groupPreviewNum
            from: 1
            to: 10
            stepSize: 1
            onMoved: v => {
                root.targetConfig.notifs.groupPreviewNum = Math.round(v);
                root.targetConfig.save();
            }
        }

        // Toasts
        SectionHeader {
            text: Es.tr(Tr.tr("Toasts"))
        }

        SelectRow {
            first: true
            label: Es.tr(qsTr("Show in fullscreen"))
            subtext: Es.tr(qsTr("Whether toasts appear over fullscreen apps"))
            configNode: root.targetConfig.utilities.toasts
            propertyName: "fullscreen"
            menuItems: root.toastFullscreenItems
            active: root.toastFullscreenItems[Math.max(0, root.toastFullscreenValues.indexOf(root.targetConfig.utilities.toasts.fullscreen))]
            onSelected: item => {
                root.targetConfig.utilities.toasts.fullscreen = root.toastFullscreenValues[root.toastFullscreenItems.indexOf(item)];
                root.targetConfig.save();
            }
        }

        StepperRow {
            label: Es.tr(qsTr("Visible toasts"))
            subtext: Es.tr(qsTr("Maximum number of toasts shown at once"))
            configNode: root.targetConfig.utilities
            propertyName: "maxToasts"
            value: root.targetConfig.utilities.maxToasts
            from: 1
            to: 10
            stepSize: 1
            onMoved: v => {
                root.targetConfig.utilities.maxToasts = Math.round(v);
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Toast transparency"))
            subtext: Es.tr(qsTr("Apply transparency and blur to toast notifications"))
            configNode: root.targetConfig.utilities.toasts
            propertyName: "transparency"
            checked: root.targetConfig.utilities.toasts.transparency
            onToggled: {
                root.targetConfig.utilities.toasts.transparency = checked;
                root.targetConfig.save();
            }
        }

        SliderRow {
            last: true
            label: Es.tr(qsTr("Base transparency"))
            configNode: root.targetConfig.utilities.toasts
            propertyName: "transparencyBase"
            valueLabel: Math.round(value * 100) + "%"
            value: root.targetConfig.utilities.toasts.transparencyBase
            enabled: root.targetConfig.utilities.toasts.transparency
            onMoved: v => {
                root.targetConfig.utilities.toasts.transparencyBase = v;
                root.targetConfig.save();
            }
        }

        // Toast events
        SectionHeader {
            text: Es.tr(Tr.tr("Toast events"))
        }

        ToggleRow {
            first: true
            text: Es.tr(qsTr("Charging changes"))
            configNode: root.targetConfig.utilities.toasts
            propertyName: "chargingChanged"
            checked: root.targetConfig.utilities.toasts.chargingChanged
            onToggled: {
                root.targetConfig.utilities.toasts.chargingChanged = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Game mode changes"))
            configNode: root.targetConfig.utilities.toasts
            propertyName: "gameModeChanged"
            checked: root.targetConfig.utilities.toasts.gameModeChanged
            onToggled: {
                root.targetConfig.utilities.toasts.gameModeChanged = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Do not disturb changes"))
            configNode: root.targetConfig.utilities.toasts
            propertyName: "dndChanged"
            checked: root.targetConfig.utilities.toasts.dndChanged
            onToggled: {
                root.targetConfig.utilities.toasts.dndChanged = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Audio output changes"))
            configNode: root.targetConfig.utilities.toasts
            propertyName: "audioOutputChanged"
            checked: root.targetConfig.utilities.toasts.audioOutputChanged
            onToggled: {
                root.targetConfig.utilities.toasts.audioOutputChanged = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Audio input changes"))
            configNode: root.targetConfig.utilities.toasts
            propertyName: "audioInputChanged"
            checked: root.targetConfig.utilities.toasts.audioInputChanged
            onToggled: {
                root.targetConfig.utilities.toasts.audioInputChanged = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Caps lock changes"))
            configNode: root.targetConfig.utilities.toasts
            propertyName: "capsLockChanged"
            checked: root.targetConfig.utilities.toasts.capsLockChanged
            onToggled: {
                root.targetConfig.utilities.toasts.capsLockChanged = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Num lock changes"))
            configNode: root.targetConfig.utilities.toasts
            propertyName: "numLockChanged"
            checked: root.targetConfig.utilities.toasts.numLockChanged
            onToggled: {
                root.targetConfig.utilities.toasts.numLockChanged = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Keyboard layout changes"))
            configNode: root.targetConfig.utilities.toasts
            propertyName: "kbLayoutChanged"
            checked: root.targetConfig.utilities.toasts.kbLayoutChanged
            onToggled: {
                root.targetConfig.utilities.toasts.kbLayoutChanged = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("VPN changes"))
            configNode: root.targetConfig.utilities.toasts
            propertyName: "vpnChanged"
            checked: root.targetConfig.utilities.toasts.vpnChanged
            onToggled: {
                root.targetConfig.utilities.toasts.vpnChanged = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            last: true
            text: Es.tr(qsTr("Now playing"))
            configNode: root.targetConfig.utilities.toasts
            propertyName: "nowPlaying"
            checked: root.targetConfig.utilities.toasts.nowPlaying
            onToggled: {
                root.targetConfig.utilities.toasts.nowPlaying = checked;
                root.targetConfig.save();
            }
        }
    }
}
