import "../../../Esp.js" as Es
import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import Caelestia.I18n
import Caelestia.Services
import qs.components.controls
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    // Lyrics backends, ordered to match config::LyricsBackend
    readonly property list<MenuItem> lyricsItems: [
        MenuItem {
            text: Es.tr(Tr.trCtx("Auto", "lyrics backend"))
        },
        MenuItem {
            text: Es.tr(Tr.trCtx("Local", "lyrics backend"))
        },
        MenuItem {
            text: Es.tr("LRCLIB")
        },
        MenuItem {
            text: Es.tr("NetEase")
        },
        MenuItem {
            text: Es.tr("Kugou")
        },
        MenuItem {
            text: Es.tr("QQ Music")
        },
        MenuItem {
            text: Es.tr("Musixmatch")
        },
        MenuItem {
            text: Es.tr("Lyrics.ovh")
        },
        MenuItem {
            text: Es.tr("Genius")
        }
    ]

    // GPU types, ordered to match config::GpuType (Auto, Nvidia, Generic, None)
    readonly property list<MenuItem> gpuItems: [
        MenuItem {
            text: Es.tr(Tr.trCtx("Auto", "gpu type"))
        },
        MenuItem {
            text: Es.tr("NVIDIA")
        },
        MenuItem {
            text: Es.tr(Tr.trCtx("Generic", "gpu type"))
        },
        MenuItem {
            text: Es.tr(Tr.trCtx("None", "gpu type"))
        }
    ]

    title: Es.tr(Tr.tr("Services"))

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        // Detected running players, used as default-player options
        Variants {
            id: playerVariants

            model: [...new Set(Players.list.map(p => Players.getIdentity(p)).filter(id => id))]

            MenuItem {
                required property string modelData

                text: modelData
                icon: modelData === GlobalConfig.services.defaultPlayer ? "check" : ""
                activeIcon: "music_note"
            }
        }

        // Notifications
        SectionHeader {
            first: true
            text: Es.tr(Tr.tr("Notifications"))
        }

        NavRow {
            first: true
            last: true
            icon: "notifications"
            text: Es.tr(Tr.tr("Notifications"))
            subtext: Es.tr(Tr.tr("Notifications, toasts, timeouts"))
            onClicked: root.nState.openSubPage(1)
        }

        // Connections
        SectionHeader {
            text: Es.tr(Tr.tr("Polling"))
        }

        StepperRow {
            first: true
            label: Es.tr(Tr.tr("Media refresh"))
            // TRANSLATORS: ms is the millisecond unit, leave it untranslated
            subtext: Es.tr(Tr.tr("How often the media position updates (ms)"))
            value: GlobalConfig.dashboard.mediaUpdateInterval
            from: 100
            to: 2000
            stepSize: 50
            onMoved: v => GlobalConfig.dashboard.mediaUpdateInterval = v
        }

        StepperRow {
            label: Es.tr(Tr.tr("System stats refresh"))
            // TRANSLATORS: CPU and GPU are hardware abbreviations, leave them untranslated
            subtext: Es.tr(Tr.tr("CPU, memory and GPU update interval (seconds)"))
            value: GlobalConfig.dashboard.resourceUpdateInterval / 1000
            from: 0.5
            to: 10
            stepSize: 0.5
            onMoved: v => GlobalConfig.dashboard.resourceUpdateInterval = Math.round(v * 1000)
        }

        StepperRow {
            last: true
            label: Es.tr(Tr.tr("Wi-Fi rescan"))
            subtext: Es.tr(Tr.tr("How often available networks are rescanned (seconds)"))
            value: GlobalConfig.nexus.networkRescanInterval / 1000
            from: 5
            to: 120
            stepSize: 5
            onMoved: v => GlobalConfig.nexus.networkRescanInterval = Math.round(v * 1000)
        }

        // Media & lyrics
        SectionHeader {
            text: Es.tr(Tr.tr("Media & lyrics"))
        }

        SelectRow {
            first: true
            label: Es.tr(Tr.tr("Lyrics backend"))
            subtext: Es.tr(Tr.tr("Source used to fetch lyrics"))
            menuItems: root.lyricsItems
            active: root.lyricsItems[Lyrics.preferredBackend] ?? root.lyricsItems[0]
            onSelected: item => Lyrics.preferredBackend = root.lyricsItems.indexOf(item)
        }

        SelectRow {
            last: true
            label: Es.tr(Tr.tr("Default player"))
            subtext: Es.tr(Tr.tr("Preferred media player when several are open"))
            menuItems: playerVariants.instances
            active: menuItems.find(i => i.text === GlobalConfig.services.defaultPlayer) ?? null
            fallbackIcon: "music_note"
            fallbackText: GlobalConfig.services.defaultPlayer || Es.tr(Tr.trCtx("Auto", "default media player"))
            onSelected: item => GlobalConfig.services.defaultPlayer = item.text
        }

        // Input increments
        SectionHeader {
            text: Es.tr(Tr.tr("Input increments"))
        }

        StepperRow {
            first: true
            label: Es.tr(Tr.tr("Volume step"))
            subtext: Es.tr(Tr.tr("Amount the volume changes per scroll (%)"))
            value: Math.round(GlobalConfig.services.audioIncrement * 100)
            from: 1
            to: 50
            stepSize: 1
            onMoved: v => GlobalConfig.services.audioIncrement = v / 100
        }

        StepperRow {
            visible: false
            label: Es.tr(Tr.tr("Brightness step"))
            subtext: Es.tr(Tr.tr("Amount the brightness changes per scroll (%)"))
            value: Math.round(GlobalConfig.services.brightnessIncrement * 100)
            from: 1
            to: 50
            stepSize: 1
            onMoved: v => GlobalConfig.services.brightnessIncrement = v / 100
        }

        StepperRow {
            last: true
            label: Es.tr(Tr.tr("Max volume"))
            subtext: Es.tr(Tr.tr("Upper limit for output volume (%)"))
            value: Math.round(GlobalConfig.services.maxVolume * 100)
            from: 50
            to: 200
            stepSize: 5
            onMoved: v => GlobalConfig.services.maxVolume = v / 100
        }

        // Service tuning
        SectionHeader {
            text: Es.tr(Tr.tr("Service tuning"))
        }

        NavRow {
            first: true
            icon: "sports_esports"
            text: Es.tr(qsTr("Game mode"))
            subtext: Es.tr(qsTr("Manage how MiDnight behaves while gaming"))
            onClicked: root.nState.openSubPage(2)
        }

        NavRow {
            icon: "chat" // Using chat since discord icon might not be available in Material icons
            text: Es.tr(qsTr("Discord Rich Presence"))
            subtext: Es.tr(qsTr("Broadcast your status to Vesktop"))
            onClicked: root.nState.openSubPage(4)
        }

        NavRow {
            icon: "picture_in_picture"
            text: Es.tr(qsTr("Picture in Picture"))
            subtext: Es.tr(qsTr("Configure PiP positioning and focus behavior"))
            onClicked: root.nState.openSubPage(5)
        }

        NavRow {
            icon: "near_me"
            text: Es.tr(qsTr("Quick Share"))
            subtext: Es.tr(qsTr("Auto-start and discoverability settings"))
            onClicked: root.nState.openSubPage(6)
        }


        SelectRow {
            Layout.fillWidth: true
            last: true
            label: Es.tr(Tr.tr("GPU"))
            subtext: Gpu.name ? Es.tr(Tr.tr("Monitoring: %1")).arg(Gpu.name) : Es.tr(Tr.tr("Override for GPU type"))
            menuOnTop: true
            menuItems: root.gpuItems
            active: root.gpuItems[GlobalConfig.services.gpuType]
            onSelected: item => GlobalConfig.services.gpuType = root.gpuItems.indexOf(item)
        }
    }
}
