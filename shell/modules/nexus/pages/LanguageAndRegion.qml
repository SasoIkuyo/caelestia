import "../../../Esp.js" as Es
import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.components.controls
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    // Temperature units (there must be one for each value of the TemperatureUnit enum)
    readonly property list<MenuItem> tempItems: [
        MenuItem {
            text: Es.tr(Tr.tr("Auto"))
            value: TemperatureUnit.Auto
        },
        MenuItem {
            text: Es.tr(Tr.tr("°C"))
            value: TemperatureUnit.Celsius
        },
        MenuItem {
            text: Es.tr(Tr.tr("°F"))
            value: TemperatureUnit.Fahrenheit
        },
        MenuItem {
            text: Es.tr(Tr.tr("K"))
            value: TemperatureUnit.Kelvin
        }
    ]

    // Data size units (there must be one for each value of the DataUnit enum)
    readonly property list<MenuItem> dataItems: [
        MenuItem {
            text: Es.tr(Tr.tr("Binary (KiB, MiB)"))
            value: DataUnit.Binary
        },
        MenuItem {
            text: Es.tr(Tr.tr("Decimal (KB, MB)"))
            value: DataUnit.Decimal
        }
    ]

    // Clock formats (there must be one for each value of the ClockFormat enum)
    readonly property list<MenuItem> clockItems: [
        MenuItem {
            text: Es.tr(Tr.tr("Auto"))
            value: ClockFormat.Auto
        },
        MenuItem {
            text: Es.tr(Tr.tr("12-hour"))
            value: ClockFormat.TwelveHour
        },
        MenuItem {
            text: Es.tr(Tr.tr("24-hour"))
            value: ClockFormat.TwentyFourHour
        }
    ]

    title: Es.tr(Tr.tr("Language & region"))

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        // Language
        SectionHeader {
            first: true
            text: Es.tr(Tr.tr("Language"))
        }

        SelectRow {
            first: true
            last: true
            label: Es.tr(Tr.tr("UI language"))
            subtext: Es.tr(Tr.tr("The language used in the shell UI"))
            active: menuItems.find(i => i.modelData === Tr.language) ?? autoLang
            onSelected: item => {
                Tr.language = item.modelData ?? ""; // qmllint disable missing-property
            }

            menuItems: [autoLang, ...langItems.instances]

            MenuItem {
                id: autoLang

                text: Es.tr(Tr.tr("Auto"))
            }

            Variants {
                id: langItems

                model: Tr.supportedLanguages

                MenuItem {
                    required property string modelData

                    text: {
                        const locale = Qt.locale(modelData);
                        return locale.name === "C" ? modelData : locale.nativeLanguageName || locale.name;
                    }
                }
            }
        }

        // Weather
        SectionHeader {
            text: Es.tr(Tr.tr("Weather"))
        }

        // Placeholder until the map-based location picker lands
        ConnectedRect {
            Layout.fillWidth: true
            first: true
            last: true
            implicitHeight: comingSoon.implicitHeight + Tokens.padding.extraLarge * 2

            ColumnLayout {
                id: comingSoon

                anchors.centerIn: parent
                width: parent.width - Tokens.padding.largeIncreased * 2
                spacing: Tokens.padding.extraSmall

                MaterialIcon {
                    Layout.alignment: Qt.AlignHCenter
                    text: "map"
                    color: Colours.palette.m3outlineVariant
                    fontStyle: Tokens.font.icon.extraLarge
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Es.tr(Tr.tr("Location picker coming soon"))
                    color: Colours.palette.m3outlineVariant
                    font: Tokens.font.title.small
                }

                StyledText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: Es.tr(Tr.tr("Choose your weather location on a map in a future update"))
                    color: Colours.palette.m3outlineVariant
                    font: Tokens.font.body.small
                }
            }
        }

        // Units
        SectionHeader {
            text: Es.tr(Tr.tr("Units"))
        }

        SelectRow {
            first: true
            label: Es.tr(Tr.tr("Temperature"))
            subtext: Es.tr(Tr.tr("Units for weather temperatures"))
            menuItems: root.tempItems
            active: root.tempItems.find(i => i.value === GlobalConfig.services.weatherUnits)
            onSelected: item => GlobalConfig.services.weatherUnits = item.value
        }

        SelectRow {
            label: Es.tr(Tr.tr("System temperatures"))
            subtext: Es.tr(Tr.tr("Units for CPU and GPU temperatures"))
            menuItems: root.tempItems
            active: root.tempItems.find(i => i.value === GlobalConfig.services.sensorUnits)
            onSelected: item => GlobalConfig.services.sensorUnits = item.value
        }

        SelectRow {
            last: true
            label: Es.tr(Tr.tr("Data sizes"))
            subtext: Es.tr(Tr.tr("Units for data sizes and network speeds"))
            menuItems: root.dataItems
            active: root.dataItems.find(i => i.value === GlobalConfig.services.dataUnits)
            onSelected: item => GlobalConfig.services.dataUnits = item.value
        }

        // Time & date
        SectionHeader {
            text: Es.tr(Tr.tr("Time & date"))
        }

        SelectRow {
            first: true
            last: true
            label: Es.tr(Tr.tr("Clock format"))
            subtext: Es.tr(Tr.tr("How times are shown across the shell"))
            menuOnTop: true
            menuItems: root.clockItems
            active: root.clockItems.find(i => i.value === GlobalConfig.services.clockFormat)
            onSelected: item => GlobalConfig.services.clockFormat = item.value
        }
    }
}
