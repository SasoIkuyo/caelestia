import "../../../../Esp.js" as Es
import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.modules.nexus.common

PageBase {
    id: root

    title: Es.tr(qsTr("Window & Lock Sizes"))
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: TokenConfig.appearance.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: Es.tr(qsTr("Lock Screen"))
        }

        SliderRow {
            first: true
            Layout.fillWidth: true
            label: Es.tr(qsTr("Height Multiplier"))
            value: TokenConfig.sizes.lock.heightMult
            valueLabel: value.toFixed(2)
            showReset: true
            onMoved: v => TokenConfig.sizes.lock.heightMult = v
            onReset: { TokenConfig.sizes.lock.resetOption("heightMult"); }
        }

        SliderRow {
            Layout.topMargin: TokenConfig.appearance.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            label: Es.tr(qsTr("Aspect Ratio"))
            value: (TokenConfig.sizes.lock.ratio - 1.0) / 1.5
            valueLabel: (1.0 + value * 1.5).toFixed(2)
            showReset: true
            onMoved: v => TokenConfig.sizes.lock.ratio = 1.0 + v * 1.5
            onReset: { TokenConfig.sizes.lock.resetOption("ratio"); }
        }

        StepperRow {
            Layout.topMargin: TokenConfig.appearance.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            label: Es.tr(qsTr("Center Card Width"))
            value: TokenConfig.sizes.lock.centerWidth
            from: 200
            to: 1000
            stepSize: 10
            showReset: true
            onMoved: v => TokenConfig.sizes.lock.centerWidth = v
            onReset: { TokenConfig.sizes.lock.resetOption("centerWidth"); }
        }

        StepperRow {
            Layout.topMargin: TokenConfig.appearance.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            label: Es.tr(qsTr("Forecast Item Width"))
            value: TokenConfig.sizes.lock.forecastItemWidth
            from: 20
            to: 100
            stepSize: 2
            showReset: true
            onMoved: v => TokenConfig.sizes.lock.forecastItemWidth = v
            onReset: { TokenConfig.sizes.lock.resetOption("forecastItemWidth"); }
        }

        StepperRow {
            Layout.topMargin: TokenConfig.appearance.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            label: Es.tr(qsTr("Large Logo Width"))
            value: TokenConfig.sizes.lock.largeLogoWidth
            from: 100
            to: 500
            stepSize: 10
            showReset: true
            onMoved: v => TokenConfig.sizes.lock.largeLogoWidth = v
            onReset: { TokenConfig.sizes.lock.resetOption("largeLogoWidth"); }
        }

        StepperRow {
            Layout.topMargin: TokenConfig.appearance.spacing.extraSmall / 2 - parent.spacing
            last: true
            Layout.fillWidth: true
            label: Es.tr(qsTr("Large Font Width"))
            value: TokenConfig.sizes.lock.largeFontWidth
            from: 100
            to: 600
            stepSize: 10
            showReset: true
            onMoved: v => TokenConfig.sizes.lock.largeFontWidth = v
            onReset: { TokenConfig.sizes.lock.resetOption("largeFontWidth"); }
        }

        SectionHeader {
            text: Es.tr(qsTr("Nexus Settings Window"))
        }

        SliderRow {
            first: true
            Layout.fillWidth: true
            label: Es.tr(qsTr("Height Multiplier"))
            value: TokenConfig.sizes.nexus.heightMult
            valueLabel: value.toFixed(2)
            showReset: true
            onMoved: v => TokenConfig.sizes.nexus.heightMult = v
            onReset: { TokenConfig.sizes.nexus.resetOption("heightMult"); }
        }

        SliderRow {
            Layout.topMargin: TokenConfig.appearance.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            label: Es.tr(qsTr("Aspect Ratio"))
            value: (TokenConfig.sizes.nexus.ratio - 1.0) / 1.5
            valueLabel: (1.0 + value * 1.5).toFixed(2)
            showReset: true
            onMoved: v => TokenConfig.sizes.nexus.ratio = 1.0 + v * 1.5
            onReset: { TokenConfig.sizes.nexus.resetOption("ratio"); }
        }

        StepperRow {
            Layout.topMargin: TokenConfig.appearance.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            label: Es.tr(qsTr("Minimum Width"))
            value: TokenConfig.sizes.nexus.minWidth
            from: 400
            to: 1200
            stepSize: 10
            showReset: true
            onMoved: v => TokenConfig.sizes.nexus.minWidth = v
            onReset: { TokenConfig.sizes.nexus.resetOption("minWidth"); }
        }

        StepperRow {
            Layout.topMargin: TokenConfig.appearance.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            label: Es.tr(qsTr("Minimum Height"))
            value: TokenConfig.sizes.nexus.minHeight
            from: 300
            to: 900
            stepSize: 10
            showReset: true
            onMoved: v => TokenConfig.sizes.nexus.minHeight = v
            onReset: { TokenConfig.sizes.nexus.resetOption("minHeight"); }
        }

        StepperRow {
            Layout.topMargin: TokenConfig.appearance.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            label: Es.tr(qsTr("Max Navigation Width"))
            value: TokenConfig.sizes.nexus.maxNavWidth
            from: 200
            to: 800
            stepSize: 10
            showReset: true
            onMoved: v => TokenConfig.sizes.nexus.maxNavWidth = v
            onReset: { TokenConfig.sizes.nexus.resetOption("maxNavWidth"); }
        }

        StepperRow {
            Layout.topMargin: TokenConfig.appearance.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            label: Es.tr(qsTr("Max Content Width"))
            value: TokenConfig.sizes.nexus.maxContentWidth
            from: 400
            to: 1200
            stepSize: 10
            showReset: true
            onMoved: v => TokenConfig.sizes.nexus.maxContentWidth = v
            onReset: { TokenConfig.sizes.nexus.resetOption("maxContentWidth"); }
        }

        StepperRow {
            Layout.topMargin: TokenConfig.appearance.spacing.extraSmall / 2 - parent.spacing
            last: true
            Layout.fillWidth: true
            label: Es.tr(qsTr("Popup Width"))
            value: TokenConfig.sizes.nexus.popupWidth
            from: 150
            to: 500
            stepSize: 10
            showReset: true
            onMoved: v => TokenConfig.sizes.nexus.popupWidth = v
            onReset: { TokenConfig.sizes.nexus.resetOption("popupWidth"); }
        }

        SectionHeader {
            text: Es.tr(qsTr("Window Information Overlay"))
        }

        SliderRow {
            first: true
            Layout.fillWidth: true
            label: Es.tr(qsTr("Height Multiplier"))
            value: TokenConfig.sizes.winfo.heightMult
            valueLabel: value.toFixed(2)
            showReset: true
            onMoved: v => TokenConfig.sizes.winfo.heightMult = v
            onReset: { TokenConfig.sizes.winfo.resetOption("heightMult"); }
        }

        StepperRow {
            Layout.topMargin: TokenConfig.appearance.spacing.extraSmall / 2 - parent.spacing
            last: true
            Layout.fillWidth: true
            label: Es.tr(qsTr("Details Pane Width"))
            value: TokenConfig.sizes.winfo.detailsWidth
            from: 200
            to: 800
            stepSize: 10
            showReset: true
            onMoved: v => TokenConfig.sizes.winfo.detailsWidth = v
            onReset: { TokenConfig.sizes.winfo.resetOption("detailsWidth"); }
        }
    }
}
