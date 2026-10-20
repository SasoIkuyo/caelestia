import "../../../../Esp.js" as Es
import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.controls
import qs.services
import qs.modules.nexus.common
import qs.modules.launcher.services

PageBase {
    id: root

    title: Es.tr(Tr.tr("Colours"))
    isSubPage: true

    readonly property list<var> variantData: [
        { name: "vibrant", label: Es.tr(qsTr("Vibrant")) },
        { name: "tonalspot", label: Es.tr(qsTr("Tonal Spot")) },
        { name: "expressive", label: Es.tr(qsTr("Expressive")) },
        { name: "fidelity", label: Es.tr(qsTr("Fidelity")) },
        { name: "content", label: Es.tr(qsTr("Content")) },
        { name: "fruitsalad", label: Es.tr(qsTr("Fruit Salad")) },
        { name: "rainbow", label: Es.tr(qsTr("Rainbow")) },
        { name: "neutral", label: Es.tr(qsTr("Neutral")) },
        { name: "monochrome", label: Es.tr(qsTr("Monochrome")) }
    ]

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        Variants {
            id: schemeItems
            model: Schemes.list
            MenuItem {
                required property var modelData
                text: `${modelData.name} ${modelData.flavour}`
                onClicked: {
                    Quickshell.execDetached(["caelestia", "scheme", "set", "-n", modelData.name, "-f", modelData.flavour]);
                }
            }
        }

        Variants {
            id: variantItems
            model: root.variantData
            MenuItem {
                required property var modelData
                text: modelData.label
                onClicked: {
                    Quickshell.execDetached(["caelestia", "scheme", "set", "-v", modelData.name]);
                }
            }
        }

        SectionHeader {
            first: true
            text: Es.tr(qsTr("General"))
        }

        ToggleRow {
            first: true
            last: true
            Layout.fillWidth: true
            text: Es.tr(qsTr("Smart colour scheme"))
            subtext: Es.tr(qsTr("Derive theme mode and variant from the wallpaper"))
            checked: GlobalConfig.services.smartScheme
            onToggled: GlobalConfig.services.smartScheme = checked
        }

        SectionHeader {
            text: Es.tr(qsTr("Scheme Settings"))
        }

        SelectRow {
            first: true
            label: Es.tr(qsTr("Colour Scheme"))
            subtext: Es.tr(qsTr("Select your base colour scheme style"))
            menuItems: schemeItems.instances
            active: {
                const current = Colours.scheme + " " + Colours.flavour;
                const list = menuItems;
                for (let i = 0; i < list.length; i++) {
                    if (list[i].text === current)
                        return list[i];
                }
                return null;
            }
            fallbackText: Colours.scheme + " " + Colours.flavour
        }

        SelectRow {
            last: true
            label: Es.tr(qsTr("Scheme Variant"))
            subtext: Es.tr(qsTr("Select the color distribution algorithm"))
            menuItems: variantItems.instances
            active: {
                const current = Colours.variant;
                let match = null;
                for (let i = 0; i < root.variantData.length; i++) {
                    if (root.variantData[i].name === current) {
                        match = root.variantData[i];
                        break;
                    }
                }
                if (!match) return null;
                const list = menuItems;
                for (let i = 0; i < list.length; i++) {
                    if (list[i].text === match.label)
                        return list[i];
                }
                return null;
            }
            fallbackText: Colours.variant
        }
    }
}
