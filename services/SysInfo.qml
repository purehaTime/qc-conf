pragma Singleton

//
// Загрузка CPU / памяти / GPU. Один опрос — один процесс-семплер,
// чтобы не плодить лишние запуски.
//

import Quickshell
import Quickshell.Io
import QtQuick
import qs.config

Singleton {
    id: root

    // ─── CPU ────────────────────────────────────────────────────────────────
    property real cpuUsage: 0          // 0..100
    property real cpuTemp: 0           // °C
    property bool cpuTempAvailable: false
    property int cpuCores: 0

    // ─── Память ─────────────────────────────────────────────────────────────
    property real memTotal: 0          // ГиБ
    property real memUsed: 0           // ГиБ
    property real memUsage: 0          // 0..100
    property real swapTotal: 0
    property real swapUsed: 0
    property real swapUsage: 0

    // ─── GPU ────────────────────────────────────────────────────────────────
    property string gpuName: ""
    property real gpuUsage: 0          // 0..100
    property real gpuMemUsed: 0        // ГиБ
    property real gpuMemTotal: 0       // ГиБ
    property real gpuTemp: 0
    property bool gpuAvailable: false
    property bool gpuTempAvailable: false

    // ─── Топ процессов (собирается только пока открыт попап) ────────────────
    property var topProcesses: []
    property int detailWatchers: 0

    readonly property string memText: `${memUsed.toFixed(1)} / ${memTotal.toFixed(1)} ГиБ`
    readonly property string gpuMemText: `${gpuMemUsed.toFixed(1)} / ${gpuMemTotal.toFixed(1)} ГиБ`

    property var _prevCpu: null

    function _parse(data: string): void {
        // ── CPU ──
        const cpuLine = data.match(/^cpu\s+(.*)$/m);
        if (cpuLine) {
            const f = cpuLine[1].trim().split(/\s+/).map(Number);
            const total = f.reduce((a, b) => a + b, 0);
            const idle = (f[3] || 0) + (f[4] || 0);
            if (root._prevCpu) {
                const dt = total - root._prevCpu[0];
                const di = idle - root._prevCpu[1];
                if (dt > 0)
                    root.cpuUsage = Math.max(0, Math.min(100, 100 * (1 - di / dt)));
            }
            root._prevCpu = [total, idle];
        }

        const cores = data.match(/^cpu\d+ /gm);
        if (cores)
            root.cpuCores = cores.length;

        // ── Память ──
        const kb = key => {
            const m = data.match(new RegExp(`^${key}:\\s+(\\d+)`, "m"));
            return m ? Number(m[1]) : 0;
        };
        const gib = v => v / 1048576;

        const memTotalKb = kb("MemTotal");
        const memAvailKb = kb("MemAvailable");
        if (memTotalKb > 0) {
            root.memTotal = gib(memTotalKb);
            root.memUsed = gib(memTotalKb - memAvailKb);
            root.memUsage = 100 * (1 - memAvailKb / memTotalKb);
        }

        const swapTotalKb = kb("SwapTotal");
        const swapFreeKb = kb("SwapFree");
        root.swapTotal = gib(swapTotalKb);
        root.swapUsed = gib(swapTotalKb - swapFreeKb);
        root.swapUsage = swapTotalKb > 0 ? 100 * (1 - swapFreeKb / swapTotalKb) : 0;

        // ── Температура CPU ──
        const t = data.match(/@@CPUTEMP\s*\n\s*(\d+)/);
        root.cpuTempAvailable = !!t;
        if (t)
            root.cpuTemp = Number(t[1]) / 1000;

        // ── GPU: nvidia-smi ──
        const nv = data.match(/@@NVIDIA\s*\n(.+)/);
        if (nv && nv[1].indexOf(",") !== -1) {
            const parts = nv[1].split(",").map(s => s.trim());
            root.gpuName = parts[0];
            root.gpuUsage = Number(parts[1]) || 0;
            root.gpuMemUsed = (Number(parts[2]) || 0) / 1024;
            root.gpuMemTotal = (Number(parts[3]) || 0) / 1024;
            root.gpuTemp = Number(parts[4]) || 0;
            root.gpuTempAvailable = true;
            root.gpuAvailable = true;
            return;
        }

        // ── GPU: amdgpu через sysfs ──
        const amd = data.match(/@@AMD\s*\n\s*(\d+)/);
        if (amd) {
            root.gpuUsage = Number(amd[1]);
            root.gpuAvailable = true;
            if (!root.gpuName)
                root.gpuName = "AMD GPU";
            const at = data.match(/@@AMDTEMP\s*\n\s*(\d+)/);
            root.gpuTempAvailable = !!at;
            if (at)
                root.gpuTemp = Number(at[1]) / 1000;
            const av = data.match(/@@AMDVRAM\s*\n\s*(\d+)\s*\n\s*(\d+)/);
            if (av) {
                root.gpuMemUsed = Number(av[1]) / 1073741824;
                root.gpuMemTotal = Number(av[2]) / 1073741824;
            }
            return;
        }

        root.gpuAvailable = false;
    }

    Process {
        id: sampler

        command: ["sh", "-c", `
            cat /proc/stat
            grep -E '^(MemTotal|MemAvailable|SwapTotal|SwapFree):' /proc/meminfo
            echo '@@CPUTEMP'
            for h in /sys/class/hwmon/hwmon*; do
                n=$(cat "$h/name" 2>/dev/null)
                case "$n" in k10temp|zenpower*|coretemp) cat "$h/temp1_input" 2>/dev/null; break ;; esac
            done
            echo '@@NVIDIA'
            command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi --query-gpu=name,utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -1
            echo '@@AMD'
            cat /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -1
            echo '@@AMDTEMP'
            for h in /sys/class/hwmon/hwmon*; do
                n=$(cat "$h/name" 2>/dev/null)
                case "$n" in amdgpu) cat "$h/temp1_input" 2>/dev/null; break ;; esac
            done
            echo '@@AMDVRAM'
            cat /sys/class/drm/card*/device/mem_info_vram_used 2>/dev/null | head -1
            cat /sys/class/drm/card*/device/mem_info_vram_total 2>/dev/null | head -1
        `]

        stdout: StdioCollector {
            onStreamFinished: root._parse(text)
        }
    }

    Timer {
        interval: Settings.metricsInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!sampler.running)
            sampler.running = true
    }

    // ─── Топ процессов ──────────────────────────────────────────────────────
    Process {
        id: psSampler

        command: ["sh", "-c", "ps -eo comm=,pcpu=,pmem= --sort=-pcpu | head -8"]

        stdout: StdioCollector {
            onStreamFinished: {
                const rows = text.trim().split("\n").filter(l => l.trim().length > 0);
                root.topProcesses = rows.map(l => {
                    const p = l.trim().split(/\s+/);
                    return {
                        name: p[0],
                        cpu: Number(p[1]) || 0,
                        mem: Number(p[2]) || 0
                    };
                });
            }
        }
    }

    Timer {
        interval: Settings.processInterval
        running: root.detailWatchers > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!psSampler.running)
            psSampler.running = true
    }
}
