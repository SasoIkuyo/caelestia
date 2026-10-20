pragma Singleton

import "../Esp.js" as Es
import QtQml
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Caelestia
import Caelestia.Config
import Caelestia.I18n
import qs.components.misc

Singleton {
    id: root

    readonly property list<MprisPlayer> list: Mpris.players.values
    readonly property MprisPlayer active: props.manualActive
        ?? list.find(p => p.isPlaying && getIdentity(p) === GlobalConfig.services.defaultPlayer)
        ?? list.find(p => p.isPlaying)
        ?? list.find(p => getIdentity(p) === GlobalConfig.services.defaultPlayer)
        ?? list[0]
        ?? null
    property alias manualActive: props.manualActive

    // Apps that expose in-app volume control over MPRIS. Sources not in this list
    // fall back to per-stream PipeWire volume control. Add new entries here.
    readonly property list<string> appVolumePlayers: [ "Spotify", "Fastpotify" ]

    // Dedup key for progressive metadata (e.g. mpv-mpris/yt-dlp player fills title then artist later).
    property string lastNowPlayingKey: ""

    function getIdentity(player: MprisPlayer): string {
        if (!player)
            return "";
        const alias = GlobalConfig.services.playerAliases.values.find(a => a.from === player.identity);
        return alias?.to ?? player.identity;
    }

    function getTitle(player: MprisPlayer): string {
        if (!player)
            return "";
        const metadata = player.metadata ?? {};
        return player.trackTitle || metadata["xesam:title"] || metadata["title"] || "";
    }

    function getArtist(player: MprisPlayer): string {
        if (!player)
            return "";
        if (player.trackArtist)
            return player.trackArtist;

        const artists = player.trackArtists ?? [];
        if (artists.length) {
            const names = [];
            for (let i = 0; i < artists.length; ++i)
                names.push(artists[i]);
            return names.join(", ");
        }

        const metadata = player.metadata ?? {};
        const value = metadata["xesam:artist"] ?? metadata["artist"] ?? "";
        return Array.isArray(value) ? value.join(", ") : String(value);
    }

    function getAlbum(player: MprisPlayer): string {
        if (!player)
            return "";
        const metadata = player.metadata ?? {};
        return player.trackAlbum || metadata["xesam:album"] || metadata["album"] || "";
    }

    function supportsAppVolume(player: MprisPlayer): bool {
        if (!player)
            return false;
        const identity = root.getIdentity(player).toLowerCase();
        return root.appVolumePlayers.some(id => identity.includes(id.toLowerCase()));
    }

    function getArtUrl(player: MprisPlayer): string {
        if (!player)
            return "";
        if (player.trackArtUrl)
            return player.trackArtUrl;

        const url = player.metadata["xesam:url"] ?? "";
        if (url.startsWith("https://www.youtube.com/watch")) {
            // Fallback for youtube
            const id = url.match(/[?&]v=([\w-]{11})/)?.[1];
            return id ? `https://img.youtube.com/vi/${id}/hqdefault.jpg` : "";
        }
        return "";
    }

    // Quickshell only emits postTrackChanged when trackid/url/title change, so late
    // artist updates (common with mpv-mpris + yt-dlp player) never retrigger it. Watch
    // title/artist too and toast once both are usable.
    function maybeToastNowPlaying(): void {
        if (!GlobalConfig.utilities.toasts.nowPlaying)
            return;

        const player = root.active;
        if (!player)
            return;

        const title = root.getTitle(player);
        const artist = root.getArtist(player);
        if (!title || !artist)
            return;

        const key = `${getIdentity(player)}\0${player.uniqueId}\0${title}\0${artist}`;
        if (key === lastNowPlayingKey)
            return;

        lastNowPlayingKey = key;
        Toaster.toast(Es.tr(Tr.tr("Now playing")), Es.tr(Tr.trCtx("%1 - %2", "track artist and title")).arg(artist).arg(title), "music_note");
    }

    onActiveChanged: lastNowPlayingKey = ""

    Connections {
        function onPostTrackChanged(): void {
            root.maybeToastNowPlaying();
        }

        function onTrackTitleChanged(): void {
            root.maybeToastNowPlaying();
        }

        function onTrackArtistChanged(): void {
            root.maybeToastNowPlaying();
        }

        target: root.active
    }

    PersistentProperties {
        id: props

        property MprisPlayer manualActive

        reloadableId: "players"
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "mediaToggle"
        description: Es.tr("Toggle media playback")
        onPressed: {
            const active = root.active;
            if (active && active.canTogglePlaying)
                active.togglePlaying();
        }
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "mediaPrev"
        description: Es.tr("Previous track")
        onPressed: {
            const active = root.active;
            if (active && active.canGoPrevious)
                active.previous();
        }
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "mediaNext"
        description: Es.tr("Next track")
        onPressed: {
            const active = root.active;
            if (active && active.canGoNext)
                active.next();
        }
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "mediaStop"
        description: Es.tr("Stop media playback")
        onPressed: root.active?.stop()
    }

    IpcHandler {
        function getActive(prop: string): string {
            const active = root.active;
            return active ? active[prop] ?? "Invalid property" : "No active player";
        }

        function list(): string {
            return root.list.map(p => root.getIdentity(p)).join("\n");
        }

        function play(): void {
            const active = root.active;
            if (active?.canPlay)
                active.play();
        }

        function pause(): void {
            const active = root.active;
            if (active?.canPause)
                active.pause();
        }

        function playPause(): void {
            const active = root.active;
            if (active?.canTogglePlaying)
                active.togglePlaying();
        }

        function previous(): void {
            const active = root.active;
            if (active?.canGoPrevious)
                active.previous();
        }

        function next(): void {
            const active = root.active;
            if (active?.canGoNext)
                active.next();
        }

        function stop(): void {
            root.active?.stop();
        }

        target: "mpris"
    }
}
