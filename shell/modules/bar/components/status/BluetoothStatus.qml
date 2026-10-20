pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Caelestia.Config
import qs.components
import qs.utils

Item {
    id: root

    required property color colour

    readonly property bool isHorizontal: Config.bar.position === "top" || Config.bar.position === "bottom"

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    Behavior on implicitHeight {
        Anim {
            type: Anim.DefaultEffects
        }
    }

    Behavior on implicitWidth {
        Anim {
            type: Anim.DefaultEffects
        }
    }

    GridLayout {
        id: layout

        columns: root.isHorizontal ? -1 : 1
        rows: root.isHorizontal ? 1 : -1
        flow: root.isHorizontal ? GridLayout.LeftToRight : GridLayout.TopToBottom
        columnSpacing: Tokens.spacing.medium / 2
        rowSpacing: Tokens.spacing.medium / 2

        // Bluetooth icon
        MaterialIcon {
            animate: true
            text: {
                if (!Bluetooth.defaultAdapter?.enabled) // qmllint disable unresolved-type
                    return "bluetooth_disabled";
                if (Bluetooth.devices.values.some(d => d.connected)) // qmllint disable unresolved-type
                    return "bluetooth_connected";
                return "bluetooth";
            }
            color: root.colour
        }

    }
}
