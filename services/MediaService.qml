pragma Singleton

//
// Управление проигрывателями (MPRIS).
// Активный плеер — тот, что играет; выбор можно закрепить вручную.
//

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

Singleton {
    id: root

    property MprisPlayer pinned: null

    readonly property var players: Mpris.players.values
    readonly property bool hasPlayer: players.length > 0

    readonly property MprisPlayer active: {
        if (pinned && players.indexOf(pinned) !== -1)
            return pinned;
        return players.find(p => p.playbackState === MprisPlaybackState.Playing) ?? players[0] ?? null;
    }

    readonly property bool playing: active?.playbackState === MprisPlaybackState.Playing
    readonly property string title: active?.trackTitle || ""
    readonly property string artist: active?.trackArtist || ""
    readonly property string album: active?.trackAlbum || ""
    readonly property string artUrl: active?.trackArtUrl || ""
    readonly property string identity: active?.identity || ""

    readonly property real position: active?.position ?? 0
    readonly property real length: active?.length ?? 0
    readonly property bool canSeek: (active?.canSeek ?? false) && (active?.lengthSupported ?? false) && length > 0

    readonly property bool volumeSupported: active?.volumeSupported ?? false
    readonly property bool muted: volumeSupported ? (active?.volume ?? 0) < 0.01 : Audio.muted

    property real _volumeBeforeMute: 1

    readonly property string label: {
        if (!active)
            return "Ничего не играет";
        if (title && artist)
            return `${artist} — ${title}`;
        return title || identity || "Проигрыватель";
    }

    function playPause(): void {
        if (active?.canTogglePlaying)
            active.togglePlaying();
    }

    function next(): void {
        if (active?.canGoNext)
            active.next();
    }

    function previous(): void {
        if (active?.canGoPrevious)
            active.previous();
    }

    function toggleMute(): void {
        if (!active) {
            Audio.toggleMute();
            return;
        }
        if (volumeSupported) {
            if (active.volume > 0.01) {
                _volumeBeforeMute = active.volume;
                active.volume = 0;
            } else {
                active.volume = _volumeBeforeMute > 0.01 ? _volumeBeforeMute : 1;
            }
        } else {
            Audio.toggleMute();
        }
    }

    function seek(seconds: real): void {
        if (active && canSeek)
            active.position = seconds;
    }

    function select(player: MprisPlayer): void {
        pinned = player;
    }

    function formatTime(seconds: real): string {
        if (!isFinite(seconds) || seconds < 0)
            return "0:00";
        const total = Math.floor(seconds);
        const h = Math.floor(total / 3600);
        const m = Math.floor((total % 3600) / 60);
        const s = total % 60;
        const pad = v => String(v).padStart(2, "0");
        return h > 0 ? `${h}:${pad(m)}:${pad(s)}` : `${m}:${pad(s)}`;
    }

    // position не обновляется сам — подталкиваем сигнал, пока идёт воспроизведение
    Timer {
        interval: 1000
        repeat: true
        running: root.playing && root.active !== null
        onTriggered: root.active.positionChanged()
    }
}
