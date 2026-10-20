pragma Singleton

import "../../Esp.js" as Es
import QtQuick
import Caelestia.I18n

QtObject {
    id: root

    readonly property list<var> pages: [
        // Appearance
        {
            label: Es.tr(Tr.tr("Wallpaper & style")),
            icon: "palette",
            description: Es.tr(Tr.tr("Wallpaper, fonts, colours")),
            category: "appearance"
        },
        {
            label: Es.tr(qsTr("Background elements")),
            icon: "wallpaper",
            description: Es.tr(qsTr("Clock, lyrics, visualiser, shimeji")),
            category: "appearance"
        },
        {
            label: Es.tr(qsTr("Shell Tokens")),
            icon: "tune",
            description: Es.tr(qsTr("Modify interface spacing, rounding, and sizing")),
            category: "appearance",
            developerOnly: true
        },

        // Connectivity
        // TODO
        // {
        //     label: Es.tr(Tr.tr("Display")),
        //     icon: "monitor",
        //     description: Es.tr(Tr.tr("Output configuration")),
        //     category: "connectivity"
        // },
        {
            label: Es.tr(Tr.tr("Network")),
            icon: "wifi",
            description: Es.tr(Tr.tr("Wi-Fi, ethernet, VPN")),
            category: "connectivity"
        },
        {
            label: Es.tr(Tr.tr("Connected devices")),
            icon: "devices_other",
            description: Es.tr(Tr.tr("Bluetooth, pairing")),
            category: "connectivity",
            noFill: true
        },
        {
            label: Es.tr(Tr.tr("Audio")),
            icon: "volume_up",
            description: Es.tr(Tr.tr("App volumes, sound devices")),
            category: "connectivity"
        },

        // System
        {
            label: Es.tr(Tr.tr("Updates")),
            icon: "update",
            description: Es.tr(Tr.tr("System updates")),
            category: "system"
        },
        {
            label: Es.tr(Tr.tr("Plugins")),
            icon: "extension",
            description: Es.tr(Tr.tr("Manage plugins")),
            category: "system"
        },

        // Shell
        {
            label: Es.tr(Tr.tr("Panels")),
            icon: "dock_to_bottom",
            description: Es.tr(Tr.tr("Dashboard, taskbar, launcher, sidebar")),
            category: "shell"
        },
        {
            label: Es.tr(Tr.tr("Apps")),
            icon: "apps",
            description: Es.tr(Tr.tr("Default apps, favourites, hidden apps")),
            category: "shell"
        },
        {
            label: Es.tr(qsTr("Hyprland")),
            icon: "layers",
            description: Es.tr(qsTr("Window manager configuration")),
            category: "shell"
        },
        {
            label: Es.tr(qsTr("Services")),
            icon: "build",
            description: Es.tr(Tr.tr("Poll intervals, lyrics backend")),
            category: "shell"
        },
        {
            label: Es.tr(Tr.tr("Language & region")),
            icon: "globe",
            description: Es.tr(Tr.tr("UI language, weather location, display units")),
            category: "shell"
        },

        // About
        {
            label: Es.tr(Tr.tr("About")),
            icon: "info",
            description: Es.tr(Tr.tr("System information, credits")),
            category: "about"
        },
    ]
}
