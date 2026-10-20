import "../../../../Esp.js" as Es
import QtQuick
import QtQuick.Layouts
import qs.components.controls
import qs.modules.nexus.common
import qs.services
import Caelestia.Config

PageBase {
    id: root

    title: Es.tr(qsTr("Picture in Picture"))

    readonly property list<MenuItem> positionItems: [
        MenuItem { text: Es.tr(qsTr("Top left")) },
        MenuItem { text: Es.tr(qsTr("Top center")) },
        MenuItem { text: Es.tr(qsTr("Top right")) },
        MenuItem { text: Es.tr(qsTr("Middle left")) },
        MenuItem { text: Es.tr(qsTr("Middle center")) },
        MenuItem { text: Es.tr(qsTr("Middle right")) },
        MenuItem { text: Es.tr(qsTr("Bottom left")) },
        MenuItem { text: Es.tr(qsTr("Bottom center")) },
        MenuItem { text: Es.tr(qsTr("Bottom right")) }
    ]

    function getPositionIndex(): int {
        const p = GlobalConfig.services.pipPosition.toLowerCase();
        if (p.includes("top")) {
            if (p.includes("left")) return 0;
            if (p.includes("center")) return 1;
            return 2;
        } else if (p.includes("middle")) {
            if (p.includes("left")) return 3;
            if (p.includes("center")) return 4;
            return 5;
        } else {
            if (p.includes("left")) return 6;
            if (p.includes("center")) return 7;
            return 8;
        }
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: Es.tr(qsTr("Behavior"))
        }

        SelectRow {
            first: true
            label: Es.tr(qsTr("Position"))
            subtext: Es.tr(qsTr("Anchor quadrant for Picture in Picture windows"))
            configNode: root.targetConfig.services
            propertyName: "pipPosition"
            menuItems: root.positionItems
            active: root.positionItems[root.getPositionIndex()]
            onSelected: item => {
                root.targetConfig.services.pipPosition = item.text.toLowerCase();
                root.targetConfig.save();
            }
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: Es.tr(qsTr("Follow active focus"))
            subtext: Es.tr(qsTr("Automatically warp PiP to the active monitor and workspace"))
            configNode: root.targetConfig.services
            propertyName: "pipFollowFocus"
            checked: root.targetConfig.services.pipFollowFocus
            onToggled: {
                root.targetConfig.services.pipFollowFocus = checked;
                root.targetConfig.save();
            }
        }
    }
}
