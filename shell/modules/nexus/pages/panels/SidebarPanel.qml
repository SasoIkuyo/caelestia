pragma ComponentBehavior: Bound

import "../../../../Esp.js" as Es
import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.controls
import qs.modules.nexus.common

PageBase {
    id: root

    title: Es.tr(Tr.tr("Sidebar"))
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.large

        SectionHeader {
            first: true
            text: Es.tr(Tr.tr("General"))
        }

        ToggleRow {
            first: true
            text: Es.tr(qsTr("Enabled"))
            configNode: root.targetConfig.sidebar
            propertyName: "enabled"
            checked: root.targetConfig.sidebar.enabled
            onToggled: {
                root.targetConfig.sidebar.enabled = checked;
                root.targetConfig.save();
            }
        }

        StepperRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            last: true
            label: Es.tr(qsTr("Drag threshold"))
            subtext: Es.tr(qsTr("Pixels dragged before the sidebar opens"))
            configNode: root.targetConfig.sidebar
            propertyName: "dragThreshold"
            value: root.targetConfig.sidebar.dragThreshold
            from: 0
            to: 200
            stepSize: 5
            onMoved: v => {
                root.targetConfig.sidebar.dragThreshold = v;
                root.targetConfig.save();
            }
        }

        // News
        SectionHeader {
            text: Es.tr(qsTr("News"))
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            last: true
            text: Es.tr(qsTr("Show News Tab"))
            subtext: Es.tr(qsTr("Show the Arch Linux news tab in the sidebar"))
            configNode: root.targetConfig.sidebar
            propertyName: "showNews"
            checked: root.targetConfig.sidebar.showNews !== false
            onToggled: {
                root.targetConfig.sidebar.showNews = checked;
                root.targetConfig.save();
            }
        }

        // AI Assistant
        SectionHeader {
            text: Es.tr(qsTr("AI Assistant"))
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: Es.tr(qsTr("Enable Assistant"))
            subtext: Es.tr(qsTr("Show the AI Assistant in the sidebar"))
            configNode: root.targetConfig.ai
            propertyName: "enableOllama"
            checked: root.targetConfig.ai.enableOllama
            onToggled: {
                root.targetConfig.ai.enableOllama = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            Layout.topMargin: Tokens.spacing.extraSmall / 2 - parent.spacing
            Layout.fillWidth: true
            text: Es.tr(qsTr("Enable Tool Usage"))
            subtext: Es.tr(qsTr("Allow the assistant to search the web, take screenshots, etc."))
            configNode: root.targetConfig.ai
            propertyName: "enableCelestialMode"
            checked: root.targetConfig.ai.enableCelestialMode
            onToggled: {
                root.targetConfig.ai.enableCelestialMode = checked;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            Layout.fillWidth: true
            text: Es.tr(qsTr("Enable OpenRouter"))
            subtext: Es.tr(qsTr("Use cloud models through the OpenRouter API"))
            configNode: root.targetConfig.ai
            propertyName: "enableOpenRouter"
            checked: root.targetConfig.ai.enableOpenRouter
            onToggled: {
                root.targetConfig.ai.enableOpenRouter = checked;
                root.targetConfig.save();
            }
        }

        TextFieldRow {
            label: Es.tr(qsTr("OpenRouter API key"))
            subtext: Es.tr(qsTr("Bearer key used for OpenRouter requests"))
            value: root.targetConfig.ai.openRouterApiKey
            placeholderText: "sk-or-..."
            onEditingFinished: value => {
                root.targetConfig.ai.openRouterApiKey = value;
                root.targetConfig.save();
            }
        }

        TextFieldRow {
            label: Es.tr(qsTr("OpenRouter model"))
            subtext: Es.tr(qsTr("Model id used when the OpenRouter provider is active"))
            value: root.targetConfig.ai.openRouterModel
            placeholderText: "openrouter/auto"
            onEditingFinished: value => {
                root.targetConfig.ai.openRouterModel = value || "openrouter/auto";
                root.targetConfig.save();
            }
        }

        ToggleRow {
            Layout.fillWidth: true
            text: Es.tr(qsTr("Enable OpenClaw"))
            subtext: Es.tr(qsTr("Use a local OpenClaw gateway as the assistant backend"))
            configNode: root.targetConfig.ai
            propertyName: "enableOpenClaw"
            checked: root.targetConfig.ai.enableOpenClaw
            onToggled: {
                root.targetConfig.ai.enableOpenClaw = checked;
                root.targetConfig.save();
            }
        }

        TextFieldRow {
            label: Es.tr(qsTr("OpenClaw gateway URL"))
            subtext: Es.tr(qsTr("Base URL of the OpenClaw gateway"))
            value: root.targetConfig.ai.openClawUrl
            placeholderText: "http://127.0.0.1:18789"
            onEditingFinished: value => {
                root.targetConfig.ai.openClawUrl = value || "http://127.0.0.1:18789";
                root.targetConfig.save();
            }
        }

        TextFieldRow {
            label: Es.tr(qsTr("OpenClaw token"))
            subtext: Es.tr(qsTr("Gateway bearer token used for authentication"))
            value: root.targetConfig.ai.openClawToken
            placeholderText: Es.tr(qsTr("Gateway token"))
            onEditingFinished: value => {
                root.targetConfig.ai.openClawToken = value;
                root.targetConfig.save();
            }
        }

        TextFieldRow {
            last: true
            label: Es.tr(qsTr("OpenClaw model"))
            subtext: Es.tr(qsTr("Model id used when the OpenClaw provider is active"))
            value: root.targetConfig.ai.openClawModel
            placeholderText: "openclaw/default"
            onEditingFinished: value => {
                root.targetConfig.ai.openClawModel = value || "openclaw/default";
                root.targetConfig.save();
            }
        }
    }
}
