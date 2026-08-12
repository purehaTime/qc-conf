pragma Singleton

//
// История буфера обмена через cliphist.
// Список подтягивается, когда открыт попап (watchers > 0).
//

import Quickshell
import Quickshell.Io
import QtQuick
import qs.config

Singleton {
    id: root

    // [{ id, preview, isImage }]
    property var entries: []
    property string query: ""
    property bool loading: false
    property bool cliphistMissing: false
    property int watchers: 0

    readonly property var filtered: {
        const q = query.trim().toLowerCase();
        if (!q)
            return entries;
        return entries.filter(e => e.preview.toLowerCase().includes(q));
    }

    function refresh(): void {
        if (lister.running)
            return;
        loading = true;
        lister.running = true;
    }

    function copy(entry): void {
        if (!entry)
            return;
        runner.command = ["sh", "-c", `cliphist decode ${entry.id} | wl-copy`];
        runner.running = true;
    }

    function remove(entry): void {
        if (!entry)
            return;
        runner.command = ["sh", "-c", `cliphist list | awk -F'\t' -v id=${entry.id} '$1==id' | cliphist delete`];
        runner.running = true;
        entries = entries.filter(e => e.id !== entry.id);
    }

    function wipe(): void {
        runner.command = ["cliphist", "wipe"];
        runner.running = true;
        entries = [];
    }

    Process {
        id: runner

        onExited: refreshTimer.restart()
    }

    Timer {
        id: refreshTimer

        interval: 150
        onTriggered: root.refresh()
    }

    Process {
        id: lister

        command: ["sh", "-c", `cliphist list 2>/dev/null | head -n ${Settings.clipboardLimit}`]

        stdout: StdioCollector {
            onStreamFinished: {
                const list = [];
                for (const line of text.split("\n")) {
                    if (!line.trim())
                        continue;
                    const tab = line.indexOf("\t");
                    if (tab < 0)
                        continue;
                    const preview = line.slice(tab + 1);
                    list.push({
                        id: line.slice(0, tab),
                        preview: preview,
                        isImage: preview.startsWith("[[ binary data")
                    });
                }
                root.entries = list;
                root.loading = false;
            }
        }
    }

    // Пока открыт попап — обновляем список
    Timer {
        interval: 2000
        repeat: true
        running: root.watchers > 0
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
