import "../../../../Esp.js" as Es
import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components.controls
import qs.modules.nexus.common
import qs.services

PageBase {
    id: root
    title: Es.tr(qsTr("Desktop lyrics"))
    isSubPage: true

    readonly property list<string> positionValues: ["top-left", "top-center", "top-right", "middle-left", "middle-center", "middle-right", "bottom-left", "bottom-center", "bottom-right"]
    readonly property list<MenuItem> positionItems: [
        MenuItem { text: Es.tr(qsTr("Top Left")) },
        MenuItem { text: Es.tr(qsTr("Top Center")) },
        MenuItem { text: Es.tr(qsTr("Top Right")) },
        MenuItem { text: Es.tr(qsTr("Middle Left")) },
        MenuItem { text: Es.tr(qsTr("Middle Center")) },
        MenuItem { text: Es.tr(qsTr("Middle Right")) },
        MenuItem { text: Es.tr(qsTr("Bottom Left")) },
        MenuItem { text: Es.tr(qsTr("Bottom Center")) },
        MenuItem { text: Es.tr(qsTr("Bottom Right")) }
    ]

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: Es.tr(qsTr("General"))
        }

        ToggleRow {
            first: true
            Layout.fillWidth: true
            text: Es.tr(qsTr("Enable desktop lyrics"))
            configNode: root.targetConfig.background.desktopLyrics
            propertyName: "enabled"
            checked: root.targetConfig.background.desktopLyrics.enabled
            onToggled: {
                root.targetConfig.background.desktopLyrics.enabled = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            text: Es.tr(qsTr("Overlay lyrics"))
            subtext: Es.tr(qsTr("Render lyrics on top of all windows"))
            configNode: root.targetConfig.background.desktopLyrics
            propertyName: "overlay"
            checked: root.targetConfig.background.desktopLyrics.overlay
            onToggled: {
                root.targetConfig.background.desktopLyrics.overlay = checked;
                root.targetConfig.save();
            }
            enabled: root.targetConfig.background.desktopLyrics.enabled
        }

        ToggleRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            text: Es.tr(qsTr("Auto-hide for fullscreen windows"))
            subtext: Es.tr(qsTr("Hide lyrics when a window is fullscreen"))
            configNode: root.targetConfig.background.desktopLyrics
            propertyName: "autoHideFullscreen"
            checked: root.targetConfig.background.desktopLyrics.autoHideFullscreen
            onToggled: {
                root.targetConfig.background.desktopLyrics.autoHideFullscreen = checked;
                root.targetConfig.save();
            }
            enabled: root.targetConfig.background.desktopLyrics.enabled
        }

        ToggleRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            last: true
            Layout.fillWidth: true
            text: Es.tr(qsTr("Auto-hide for tiled windows"))
            subtext: Es.tr(qsTr("Hide lyrics when tiled windows are open"))
            configNode: root.targetConfig.background.desktopLyrics
            propertyName: "autoHideTiled"
            checked: root.targetConfig.background.desktopLyrics.autoHideTiled
            onToggled: {
                root.targetConfig.background.desktopLyrics.autoHideTiled = checked;
                root.targetConfig.save();
            }
            enabled: root.targetConfig.background.desktopLyrics.enabled
        }

        SectionHeader {
            text: Es.tr(qsTr("Appearance"))
        }

        SelectRow {
            first: true
            Layout.fillWidth: true
            label: Es.tr(qsTr("Position"))
            configNode: root.targetConfig.background.desktopLyrics
            propertyName: "position"
            menuItems: root.positionItems
            active: root.positionItems[root.positionValues.indexOf(root.targetConfig.background.desktopLyrics.position)] ?? root.positionItems[4]
            onSelected: item => {
                let idx = root.positionItems.indexOf(item);
                if (idx !== -1) {
                    root.targetConfig.background.desktopLyrics.position = root.positionValues[idx];
                    root.targetConfig.save();
                }
            }
        }

        SliderRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            label: Es.tr(qsTr("Scale"))
            configNode: root.targetConfig.background.desktopLyrics
            propertyName: "scale"
            value: (root.targetConfig.background.desktopLyrics.scale - 0.5) / 2.5
            valueLabel: (0.5 + value * 2.5).toFixed(1) + "x"
            onMoved: v => {
                root.targetConfig.background.desktopLyrics.scale = 0.5 + v * 2.5;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            last: true
            Layout.fillWidth: true
            text: Es.tr(qsTr("Invert colors"))
            subtext: Es.tr(qsTr("Invert the lyrics color when using light wallpaper"))
            configNode: root.targetConfig.background.desktopLyrics
            propertyName: "invertColors"
            checked: root.targetConfig.background.desktopLyrics.invertColors
            onToggled: {
                root.targetConfig.background.desktopLyrics.invertColors = checked;
                root.targetConfig.save();
            }
        }

        SectionHeader {
            text: Es.tr(qsTr("Typography"))
        }

        Variants {
            id: lyricsFontItems

            model: [""].concat(Fonts.available)

            MenuItem {
                required property string modelData

                text: modelData || Es.tr(qsTr("Default"))
                value: modelData
            }
        }

        SelectRow {
            first: true
            last: true
            Layout.fillWidth: true
            label: Es.tr(qsTr("Lyrics font"))
            subtext: Es.tr(qsTr("Typeface used by the desktop lyrics"))
            menuItems: lyricsFontItems.instances
            active: lyricsFontItems.instances.find(i => i.value === LyricsStyle.font) ?? null
            fallbackText: LyricsStyle.font || Es.tr(qsTr("Default"))
            onSelected: item => {
                LyricsStyle.font = item.value ?? "";
            }
        }

        SectionHeader {
            text: Es.tr(qsTr("Background"))
        }

        ToggleRow {
            first: true
            Layout.fillWidth: true
            text: Es.tr(qsTr("Enable background"))
            configNode: root.targetConfig.background.desktopLyrics.background
            propertyName: "enabled"
            checked: root.targetConfig.background.desktopLyrics.background.enabled
            onToggled: {
                root.targetConfig.background.desktopLyrics.background.enabled = checked;
                root.targetConfig.save();
            }
        }

        SliderRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            label: Es.tr(qsTr("Opacity"))
            configNode: root.targetConfig.background.desktopLyrics.background
            propertyName: "opacity"
            value: root.targetConfig.background.desktopLyrics.background.opacity
            valueLabel: Math.round(value * 100) + "%"
            onMoved: v => {
                root.targetConfig.background.desktopLyrics.background.opacity = v;
                root.targetConfig.save();
            }
            enabled: root.targetConfig.background.desktopLyrics.background.enabled
        }

        ToggleRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            last: true
            Layout.fillWidth: true
            text: Es.tr(qsTr("Blur"))
            configNode: root.targetConfig.background.desktopLyrics.background
            propertyName: "blur"
            checked: root.targetConfig.background.desktopLyrics.background.blur
            onToggled: {
                root.targetConfig.background.desktopLyrics.background.blur = checked;
                root.targetConfig.save();
            }
            enabled: root.targetConfig.background.desktopLyrics.background.enabled
        }

        SectionHeader {
            text: Es.tr(qsTr("Shadow"))
        }

        ToggleRow {
            first: true
            Layout.fillWidth: true
            text: Es.tr(qsTr("Enable shadow"))
            configNode: root.targetConfig.background.desktopLyrics.shadow
            propertyName: "enabled"
            checked: root.targetConfig.background.desktopLyrics.shadow.enabled
            onToggled: {
                root.targetConfig.background.desktopLyrics.shadow.enabled = checked;
                root.targetConfig.save();
            }
        }

        SliderRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            label: Es.tr(qsTr("Opacity"))
            configNode: root.targetConfig.background.desktopLyrics.shadow
            propertyName: "opacity"
            value: root.targetConfig.background.desktopLyrics.shadow.opacity
            valueLabel: Math.round(value * 100) + "%"
            onMoved: v => {
                root.targetConfig.background.desktopLyrics.shadow.opacity = v;
                root.targetConfig.save();
            }
            enabled: root.targetConfig.background.desktopLyrics.shadow.enabled
        }

        SliderRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            last: true
            Layout.fillWidth: true
            label: Es.tr(qsTr("Blur strength"))
            configNode: root.targetConfig.background.desktopLyrics.shadow
            propertyName: "blur"
            value: root.targetConfig.background.desktopLyrics.shadow.blur / 2.0
            valueLabel: (value * 2.0).toFixed(1)
            onMoved: v => {
                root.targetConfig.background.desktopLyrics.shadow.blur = v * 2.0;
                root.targetConfig.save();
            }
            enabled: root.targetConfig.background.desktopLyrics.shadow.enabled
        }
    }
}
