pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import qs.utils

// Per-user font choice for the desktop lyrics widget. Stored separately from
// shell.json so the lyrics font can change without touching the UI body font.
//
// PersistentProperties only survives a config reload (it keeps the old QML
// object in memory), not a full shell restart, so persist to a real file.
Singleton {
    id: root

    FileView {
        id: store

        path: `${Paths.state}/lyrics.json`
        printErrors: false
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: adapter

            property string font: "Spotify Mix UI"
        }
    }

    property alias font: adapter.font
    onFontChanged: store.writeAdapter()
}
