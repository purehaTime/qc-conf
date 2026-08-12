pragma Singleton

//
// Раскладки клавиатуры через niri IPC.
// Слушаем event-stream, поэтому индикатор меняется мгновенно.
//

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var layouts: []       // полные названия, как их отдаёт niri
    property int currentIndex: 0
    readonly property bool available: layouts.length > 0

    readonly property string currentName: layouts[currentIndex] ?? "—"
    readonly property string currentShort: shortName(currentName)

    // "English (US)" → EN, "Russian" → RU
    readonly property var _codes: ({
        "english": "EN",
        "russian": "RU",
        "ukrainian": "UA",
        "german": "DE",
        "french": "FR",
        "spanish": "ES",
        "italian": "IT",
        "polish": "PL",
        "czech": "CZ",
        "japanese": "JA",
        "chinese": "ZH",
        "korean": "KO",
        "arabic": "AR",
        "hebrew": "HE",
        "turkish": "TR",
        "greek": "EL",
        "belarusian": "BY",
        "kazakh": "KZ",
        "armenian": "AM",
        "georgian": "GE"
    })

    function shortName(name: string): string {
        if (!name)
            return "—";
        const key = name.toLowerCase().split(/[\s(,]/)[0];
        return _codes[key] ?? name.slice(0, 2).toUpperCase();
    }

    function switchTo(index: int): void {
        Quickshell.execDetached(["niri", "msg", "action", "switch-layout", String(index)]);
    }

    function next(): void {
        Quickshell.execDetached(["niri", "msg", "action", "switch-layout", "next"]);
    }

    function prev(): void {
        Quickshell.execDetached(["niri", "msg", "action", "switch-layout", "prev"]);
    }

    function _applyState(state): void {
        if (!state)
            return;
        root._failures = 0;
        if (state.names)
            root.layouts = state.names;
        if (state.current_idx !== undefined)
            root.currentIndex = state.current_idx;
    }

    // Начальное состояние
    Process {
        running: true
        command: ["niri", "msg", "-j", "keyboard-layouts"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root._applyState(JSON.parse(text));
                } catch (e) {}
            }
        }
    }

    // Живые события
    Process {
        id: events

        running: true
        command: ["niri", "msg", "-j", "event-stream"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (!data.trim())
                    return;
                let ev;
                try {
                    ev = JSON.parse(data);
                } catch (e) {
                    return;
                }
                if (ev.KeyboardLayoutsChanged)
                    root._applyState(ev.KeyboardLayoutsChanged.keyboard_layouts);
                else if (ev.KeyboardLayoutSwitched)
                    root.currentIndex = ev.KeyboardLayoutSwitched.idx;
            }
        }

        // niri перезапустился — переподключаемся (с нарастающей паузой,
        // чтобы не плодить процессы, если niri вообще нет)
        onExited: {
            root._failures++;
            reconnect.restart();
        }
    }

    property int _failures: 0

    Timer {
        id: reconnect

        interval: Math.min(30000, 2000 * Math.pow(2, Math.min(root._failures, 4)))
        onTriggered: if (!events.running)
            events.running = true
    }
}
