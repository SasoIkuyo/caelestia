pragma ComponentBehavior: Bound

import "../../../../../Esp.js" as Es
import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: Es.tr(qsTr("Spotify"))
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: Es.tr(qsTr("Configuration"))
        }

        ToggleRow {
            first: true
            text: Es.tr(qsTr("Background"))
            subtext: Es.tr(qsTr("Render a solid background behind the Spotify widget"))
            configNode: root.targetConfig.bar.spotify
            propertyName: "background"
            checked: root.targetConfig.bar.spotify.background
            onToggled: {
                root.targetConfig.bar.spotify.background = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Show visualizer"))
            subtext: Es.tr(qsTr("Display animated frequency visualizer bars"))
            configNode: root.targetConfig.bar.spotify
            propertyName: "showVisualiser"
            checked: root.targetConfig.bar.spotify.showVisualiser
            onToggled: {
                root.targetConfig.bar.spotify.showVisualiser = checked;
                root.targetConfig.save();
            }
        }

        StepperRow {
            label: Es.tr(qsTr("Max title length"))
            subtext: Es.tr(qsTr("Cut off character count for track title"))
            configNode: root.targetConfig.bar.spotify
            propertyName: "maxTitleLength"
            value: root.targetConfig.bar.spotify.maxTitleLength
            from: 5
            to: 100
            stepSize: 1
            onMoved: v => {
                root.targetConfig.bar.spotify.maxTitleLength = v;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Inverted text direction"))
            subtext: Es.tr(qsTr("Rotate text in the opposite direction when the bar is vertical"))
            configNode: root.targetConfig.bar.spotify
            propertyName: "inverted"
            checked: root.targetConfig.bar.spotify.inverted
            onToggled: {
                root.targetConfig.bar.spotify.inverted = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Auto-hide"))
            subtext: Es.tr(qsTr("Hide the widget when there is no media source available"))
            configNode: root.targetConfig.bar.spotify
            propertyName: "autoHide"
            checked: root.targetConfig.bar.spotify.autoHide
            onToggled: {
                root.targetConfig.bar.spotify.autoHide = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            last: true
            text: Es.tr(qsTr("Horizontal volume slider"))
            subtext: Es.tr(qsTr("Place a horizontal volume slider below the playback controls in the popout"))
            configNode: root.targetConfig.bar.spotify
            propertyName: "horizontalVolume"
            checked: root.targetConfig.bar.spotify.horizontalVolume
            onToggled: {
                root.targetConfig.bar.spotify.horizontalVolume = checked;
                root.targetConfig.save();
            }
        }
    }
}
