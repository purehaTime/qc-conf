pragma Singleton

//
// Звук через PipeWire: громкость/мьют вывода и ввода, выбор устройств.
//

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import qs.config

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)
    readonly property var sources: Pipewire.nodes.values.filter(n => !n.isSink && !n.isStream && n.audio)

    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property int volumePercent: Math.round(volume * 100)

    readonly property real inputVolume: source?.audio?.volume ?? 0
    readonly property bool inputMuted: source?.audio?.muted ?? false
    readonly property int inputVolumePercent: Math.round(inputVolume * 100)

    readonly property string sinkName: sink?.nickname || sink?.description || sink?.name || "Нет устройства"
    readonly property string sourceName: source?.nickname || source?.description || source?.name || "Нет микрофона"

    readonly property string icon: {
        if (!sink || muted)
            return "volume_off";
        if (volumePercent === 0)
            return "volume_mute";
        if (volumePercent < 50)
            return "volume_down";
        return "volume_up";
    }

    function setVolume(v: real): void {
        if (!sink?.audio)
            return;
        sink.audio.muted = false;
        sink.audio.volume = Math.max(0, Math.min(Settings.volumeMax, v));
    }

    function changeVolume(delta: real): void {
        setVolume(root.volume + delta);
    }

    function toggleMute(): void {
        if (sink?.audio)
            sink.audio.muted = !sink.audio.muted;
    }

    function setInputVolume(v: real): void {
        if (!source?.audio)
            return;
        source.audio.muted = false;
        source.audio.volume = Math.max(0, Math.min(1, v));
    }

    function toggleInputMute(): void {
        if (source?.audio)
            source.audio.muted = !source.audio.muted;
    }

    function setDefaultSink(node: PwNode): void {
        Pipewire.preferredDefaultAudioSink = node;
    }

    function setDefaultSource(node: PwNode): void {
        Pipewire.preferredDefaultAudioSource = node;
    }

    function nodeLabel(node: PwNode): string {
        return node?.nickname || node?.description || node?.name || "";
    }

    // Связываем узлы, иначе их свойства (громкость/мьют) не обновляются
    PwObjectTracker {
        objects: [...root.sinks, ...root.sources, root.sink, root.source].filter(n => n)
    }
}
