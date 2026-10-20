import "../../../../Esp.js" as Es
import QtQuick
import QtQuick.Layouts
import qs.components.controls
import qs.modules.nexus.common
import qs.services
import Caelestia.Config

PageBase {
    id: root

    title: Es.tr(qsTr("Quick Share"))

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: Es.tr(qsTr("Startup"))
        }

        ToggleRow {
            first: true
            last: true
            text: Es.tr(qsTr("Auto-start on launch"))
            subtext: Es.tr(qsTr("Enable Quick Share when the shell starts"))
            configNode: root.targetConfig.services
            propertyName: "quickShareAutoStart"
            checked: root.targetConfig.services.quickShareAutoStart
            onToggled: {
                root.targetConfig.services.quickShareAutoStart = checked;
                root.targetConfig.save();
            }
        }

        SectionHeader {
            text: Es.tr(qsTr("Status"))
        }

        ToggleRow {
            first: true
            last: true
            text: Es.tr(qsTr("Enable Quick Share"))
            subtext: QuickShare.isEnabled ? Es.tr(qsTr("Discoverable by nearby devices")) : Es.tr(qsTr("Disabled"))
            checked: QuickShare.isEnabled
            onToggled: {
                QuickShare.setEnabled(checked);
                QuickShare.setVisible(checked);
            }
        }
    }
}
