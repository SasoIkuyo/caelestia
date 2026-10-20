pragma ComponentBehavior: Bound

import "../../../../Esp.js" as Es
import QtQuick.Layouts
import Caelestia.Config
import Caelestia.I18n
import qs.components.controls
import qs.modules.nexus.common

PageBase {
    id: root

    readonly property list<MenuItem> positionItems: [
        MenuItem {
            property string value: "top"

            text: Es.tr(qsTr("Top"))
        },
        MenuItem {
            property string value: "bottom"

            text: Es.tr(qsTr("Bottom"))
        },
        MenuItem {
            property string value: "left"

            text: Es.tr(qsTr("Left"))
        },
        MenuItem {
            property string value: "right"

            text: Es.tr(qsTr("Right"))
        }
    ]

    title: Es.tr(qsTr("Taskbar"))
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        // Behaviour
        SectionHeader {
            first: true
            text: Es.tr(Tr.tr("Behaviour"))
        }

        ToggleRow {
            first: true
            text: Es.tr(qsTr("Persistent"))
            subtext: Es.tr(qsTr("Keep the bar visible at all times"))
            configNode: root.targetConfig.bar
            propertyName: "persistent"
            checked: root.targetConfig.bar.persistent
            onToggled: {
                root.targetConfig.bar.persistent = checked;
                root.targetConfig.save();
            }
        }

        SelectRow {
            Layout.fillWidth: true
            label: Es.tr(qsTr("Position"))
            subtext: Es.tr(qsTr("Screen edge to place the bar on"))
            configNode: root.targetConfig.bar
            propertyName: "position"
            active: {
                for (let i = 0; i < positionItems.length; i++) {
                    if (positionItems[i].value === root.targetConfig.bar.position)
                        return positionItems[i];
                }
                return positionItems[0];
            }
            menuItems: positionItems
            onSelected: item => {
                root.targetConfig.bar.position = item.value;
                root.targetConfig.save();
            }
        }

        ToggleRow {
            text: Es.tr(qsTr("Show on hover"))
            subtext: Es.tr(qsTr("Reveal the bar when the cursor reaches the screen edge"))
            configNode: root.targetConfig.bar
            propertyName: "showOnHover"
            checked: root.targetConfig.bar.showOnHover
            onToggled: {
                root.targetConfig.bar.showOnHover = checked;
                root.targetConfig.save();
            }
        }

        StepperRow {
            last: true
            label: Es.tr(qsTr("Drag threshold"))
            subtext: Es.tr(qsTr("Pixels dragged before the bar reveals"))
            configNode: root.targetConfig.bar
            propertyName: "dragThreshold"
            value: root.targetConfig.bar.dragThreshold
            from: 0
            to: 200
            stepSize: 5
            onMoved: v => {
                root.targetConfig.bar.dragThreshold = v;
                root.targetConfig.save();
            }
        }

        // Components
        SectionHeader {
            text: Es.tr(Tr.tr("Components"))
        }

        NavRow {
            first: true
            icon: "view_agenda"
            text: Es.tr(qsTr("Taskbar components"))
            subtext: Es.tr(qsTr("Add, remove or reorder components"))
            onClicked: root.nState.openSubPage(6)
        }

        NavRow {
            icon: "workspaces"
            text: Es.tr(qsTr("Workspaces"))
            subtext: Es.tr(qsTr("Indicators, window icons"))
            onClicked: root.nState.openSubPage(7)
        }

        NavRow {
            icon: "web_asset"
            text: Es.tr(qsTr("Active window"))
            subtext: Es.tr(qsTr("Title display, popout"))
            onClicked: root.nState.openSubPage(8)
        }

        NavRow {
            icon: "dock"
            text: Es.tr(qsTr("Dock"))
            subtext: Es.tr(qsTr("Positioning, recoloring"))
            onClicked: root.nState.openSubPage(12)
        }

        NavRow {
            icon: "widgets"
            text: Es.tr(qsTr("Tray"))
            subtext: Es.tr(qsTr("System tray icons"))
            onClicked: root.nState.openSubPage(9)
        }

        NavRow {
            icon: "signal_cellular_alt"
            text: Es.tr(qsTr("Status icons"))
            subtext: Es.tr(qsTr("Visible indicators"))
            onClicked: root.nState.openSubPage(10)
        }

        NavRow {
            icon: "schedule"
            text: Es.tr(qsTr("Clock"))
            subtext: Es.tr(qsTr("Date, icon, background"))
            onClicked: root.nState.openSubPage(11)
        }

        NavRow {
            icon: "code"
            text: Es.tr(qsTr("GitHub"))
            subtext: Es.tr(qsTr("Contributions, token setup"))
            onClicked: root.nState.openSubPage(13)
        }

        NavRow {
            last: true
            icon: "music_note"
            text: Es.tr(qsTr("Spotify"))
            subtext: Es.tr(qsTr("Visualizer, title length, background"))
            onClicked: root.nState.openSubPage(14)
        }

        // Scroll actions
        SectionHeader {
            text: Es.tr(Tr.tr("Scroll actions"))
        }

        ToggleRow {
            first: true
            text: Es.tr(Tr.tr("Workspaces"))
            subtext: Es.tr(Tr.tr("Scroll over the workspace indicator to switch workspaces"))
            checked: Config.bar.scrollActions.workspaces
            onToggled: GlobalConfig.bar.scrollActions.workspaces = checked
        }

        ToggleRow {
            text: Es.tr(Tr.tr("Volume"))
            subtext: Es.tr(Tr.tr("Scroll on the top half of the bar to adjust volume"))
            checked: Config.bar.scrollActions.volume
            onToggled: GlobalConfig.bar.scrollActions.volume = checked
        }

        ToggleRow {
            visible: false
            last: true
            text: Es.tr(Tr.tr("Brightness"))
            subtext: Es.tr(Tr.tr("Scroll on the bottom half of the bar to adjust brightness"))
            checked: Config.bar.scrollActions.brightness
            onToggled: GlobalConfig.bar.scrollActions.brightness = checked
        }
    }
}
