pragma Singleton

//
// Яркость. Два бэкенда:
//   backlight — /sys/class/backlight (ноутбуки), пишем через brightnessctl
//   ddcutil   — внешние мониторы по DDC/CI (медленно, поэтому запись с задержкой)
//

import Quickshell
import Quickshell.Io
import QtQuick
import qs.config

Singleton {
    id: root

    // [{ backend, id, label, value (0..100), raw, max }]
    property var devices: []
    property bool probing: false
    property bool probed: false

    readonly property bool available: devices.length > 0
    readonly property var primary: devices.length > 0 ? devices[0] : null
    readonly property int percent: primary ? Math.round(primary.value) : 0

    readonly property string icon: {
        if (!available)
            return "brightness_medium";
        if (percent >= 66)
            return "brightness_high";
        if (percent >= 33)
            return "brightness_6";
        return "brightness_low";
    }

    property var _pending: ({})

    function refresh(): void {
        if (probing || Settings.brightnessBackend === "none")
            return;
        probing = true;
        prober.running = true;
    }

    function setValue(index: int, value: real): void {
        if (index < 0 || index >= devices.length)
            return;
        const v = Math.max(1, Math.min(100, Math.round(value)));
        const copy = devices.slice();
        copy[index] = Object.assign({}, copy[index], {
            value: v
        });
        devices = copy;
        _pending[copy[index].id] = {
            backend: copy[index].backend,
            value: v
        };
        writeTimer.restart();
    }

    function change(index: int, delta: real): void {
        if (index < 0 || index >= devices.length)
            return;
        setValue(index, devices[index].value + delta);
    }

    function _flush(): void {
        const parts = [];
        for (const id in _pending) {
            const item = _pending[id];
            if (item.backend === "backlight")
                parts.push(`brightnessctl -d '${id}' -q set '${item.value}%'`);
            else
                parts.push(`ddcutil --display '${id}' setvcp 10 ${item.value} --noverify`);
        }
        _pending = ({});
        if (parts.length === 0)
            return;
        writer.command = ["sh", "-c", parts.join("; ")];
        writer.running = true;
    }

    Timer {
        id: writeTimer

        interval: 180
        onTriggered: if (!writer.running)
            root._flush()
        else
            restart()
    }

    Process {
        id: writer
    }

    Process {
        id: prober

        command: ["sh", "-c", `
            backend='${Settings.brightnessBackend}'
            has_bl=$(ls -A /sys/class/backlight 2>/dev/null)
            if [ "$backend" != "ddcutil" ] && [ -n "$has_bl" ]; then
                for d in /sys/class/backlight/*; do
                    cur=$(cat "$d/brightness" 2>/dev/null)
                    max=$(cat "$d/max_brightness" 2>/dev/null)
                    [ -n "$max" ] && [ "$max" -gt 0 ] && echo "BL|$(basename "$d")|$(basename "$d")|$cur|$max"
                done
            elif [ "$backend" != "backlight" ] && command -v ddcutil >/dev/null 2>&1; then
                ddcutil --brief detect 2>/dev/null | awk '/^Display /{d=$2} /Monitor:/{print d" "$2}' | while read -r num mon; do
                    line=$(ddcutil --display "$num" --brief getvcp 10 2>/dev/null)
                    cur=$(echo "$line" | awk '{print $4}')
                    max=$(echo "$line" | awk '{print $5}')
                    [ -n "$cur" ] && echo "DDC|$num|$mon|$cur|$max"
                done
            fi
        `]

        stdout: StdioCollector {
            onStreamFinished: {
                const list = [];
                for (const line of text.trim().split("\n")) {
                    const f = line.split("|");
                    if (f.length < 5)
                        continue;
                    const max = Number(f[4]) || 100;
                    const raw = Number(f[3]) || 0;
                    const isBl = f[0] === "BL";
                    let label = f[2];
                    if (!isBl) {
                        const parts = label.split(":");
                        label = parts.length > 1 ? parts[1] : label;
                    }
                    list.push({
                        backend: isBl ? "backlight" : "ddcutil",
                        id: f[1],
                        label: label,
                        raw: raw,
                        max: max,
                        value: Math.round(100 * raw / max)
                    });
                }
                root.devices = list;
                root.probing = false;
                root.probed = true;
            }
        }
    }

    Timer {
        interval: 400
        running: true
        onTriggered: root.refresh()
    }
}
