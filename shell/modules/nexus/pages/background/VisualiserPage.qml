import "../../../../Esp.js" as Es
import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components.controls
import qs.modules.nexus.common

PageBase {
    id: root
    title: Es.tr(qsTr("Background visualiser"))
    isSubPage: true

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
            text: Es.tr(qsTr("Enable background visualiser"))
            configNode: root.targetConfig.background.visualiser
            propertyName: "enabled"
            checked: root.targetConfig.background.visualiser.enabled
            onToggled: {
                root.targetConfig.background.visualiser.enabled = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            text: Es.tr(qsTr("Auto-hide visualiser"))
            subtext: Es.tr(qsTr("Hide visualiser when a window is open"))
            configNode: root.targetConfig.background.visualiser
            propertyName: "autoHide"
            checked: root.targetConfig.background.visualiser.autoHide
            onToggled: {
                root.targetConfig.background.visualiser.autoHide = checked;
                root.targetConfig.save();
            }
            enabled: root.targetConfig.background.visualiser.enabled
        }

        ToggleRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            text: Es.tr(qsTr("Blur background"))
            subtext: Es.tr(qsTr("Blur the wallpaper behind the visualiser"))
            configNode: root.targetConfig.background.visualiser
            propertyName: "blur"
            checked: root.targetConfig.background.visualiser.blur
            onToggled: {
                root.targetConfig.background.visualiser.blur = checked;
                root.targetConfig.save();
            }
            enabled: root.targetConfig.background.visualiser.enabled
        }

        SelectRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            last: true
            Layout.fillWidth: true
            label: Es.tr(qsTr("Renderer"))
            configNode: root.targetConfig.background.visualiser
            propertyName: "renderer"
            menuItems: [
                MenuItem { text: Es.tr(qsTr("GPU (Shader)")) },
                MenuItem { text: Es.tr(qsTr("CPU (QPainter)")) }
            ]
            active: root.targetConfig.background.visualiser.renderer === "cpu" ? menuItems[1] : menuItems[0]
            onSelected: item => {
                root.targetConfig.background.visualiser.renderer = item === menuItems[1] ? "cpu" : "gpu";
                root.targetConfig.save();
            }
            enabled: root.targetConfig.background.visualiser.enabled
        }

        SectionHeader {
            text: Es.tr(qsTr("Appearance"))
        }

        SliderRow {
            first: true
            Layout.fillWidth: true
            label: Es.tr(qsTr("Rounding"))
            configNode: root.targetConfig.background.visualiser
            propertyName: "rounding"
            value: root.targetConfig.background.visualiser.rounding / 10.0
            valueLabel: (value * 10.0).toFixed(1)
            onMoved: v => {
                root.targetConfig.background.visualiser.rounding = v * 10.0;
                root.targetConfig.save();
            }
        }

        SliderRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            label: Es.tr(qsTr("Spacing"))
            configNode: root.targetConfig.background.visualiser
            propertyName: "spacing"
            value: root.targetConfig.background.visualiser.spacing / 10.0
            valueLabel: (value * 10.0).toFixed(1)
            onMoved: v => {
                root.targetConfig.background.visualiser.spacing = v * 10.0;
                root.targetConfig.save();
            }
        }

        StepperRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            last: true
            Layout.fillWidth: true
            label: Es.tr(qsTr("Visualiser bars"))
            subtext: Es.tr(qsTr("Number of bars in the audio visualisers"))
            configNode: root.targetConfig.services
            propertyName: "visualiserBars"
            value: root.targetConfig.services.visualiserBars
            from: 10
            to: 120
            stepSize: 2
            onMoved: v => {
                root.targetConfig.services.visualiserBars = v;
                root.targetConfig.save();
            }
        }
    }
}
