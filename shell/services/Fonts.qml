pragma Singleton

import QtQuick
import Quickshell

// Font families that look good for large clock / lyric text.
// Keep this list curated: Qt.fontFamilies() also exposes every Noto script
// and icon font installed on the system, which makes a settings menu unusable.
Singleton {
    readonly property var curated: [
        "Spotify Mix UI Title",
        "Spotify Mix UI",
        "Spotify Mix UI Title Extrabold",
        "Google Sans Flex",
        "GoogleSansFlex",
        "Rubik",
        "Fira Sans",
        "Fira Sans Condensed",
        "Adwaita Sans",
        "Noto Sans",
        "Liberation Sans",
        "FreeSans",
        "JetBrainsMono Nerd Font",
        "FiraCode Nerd Font",
        "CaskaydiaCove Nerd Font",
        "Hack"
    ]

    readonly property var available: {
        const all = Qt.fontFamilies();
        return curated.filter(family => all.indexOf(family) !== -1);
    }
}
