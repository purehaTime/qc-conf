pragma Singleton

//
// Цветовая схема: Catppuccin (4 варианта).
// Выбранный вариант и акцент сохраняются в ~/.local/state/quickshell/.../theme.json
//

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // ─── Палитры ────────────────────────────────────────────────────────────
    readonly property var palettes: ({
        "mocha": {
            "name": "Mocha",
            "dark": true,
            "crust": "#11111b", "mantle": "#181825", "base": "#1e1e2e",
            "surface0": "#313244", "surface1": "#45475a", "surface2": "#585b70",
            "overlay0": "#6c7086", "overlay1": "#7f849c", "overlay2": "#9399b2",
            "subtext0": "#a6adc8", "subtext1": "#bac2de", "text": "#cdd6f4",
            "rosewater": "#f5e0dc", "flamingo": "#f2cdcd", "pink": "#f5c2e7", "mauve": "#cba6f7",
            "red": "#f38ba8", "maroon": "#eba0ac", "peach": "#fab387", "yellow": "#f9e2af",
            "green": "#a6e3a1", "teal": "#94e2d5", "sky": "#89dceb", "sapphire": "#74c7ec",
            "blue": "#89b4fa", "lavender": "#b4befe"
        },
        "macchiato": {
            "name": "Macchiato",
            "dark": true,
            "crust": "#181926", "mantle": "#1e2030", "base": "#24273a",
            "surface0": "#363a4f", "surface1": "#494d64", "surface2": "#5b6078",
            "overlay0": "#6e738d", "overlay1": "#8087a2", "overlay2": "#939ab7",
            "subtext0": "#a5adcb", "subtext1": "#b8c0e0", "text": "#cad3f5",
            "rosewater": "#f4dbd6", "flamingo": "#f0c6c6", "pink": "#f5bde6", "mauve": "#c6a0f6",
            "red": "#ed8796", "maroon": "#ee99a0", "peach": "#f5a97f", "yellow": "#eed49f",
            "green": "#a6da95", "teal": "#8bd5ca", "sky": "#91d7e3", "sapphire": "#7dc4e4",
            "blue": "#8aadf4", "lavender": "#b7bdf8"
        },
        "frappe": {
            "name": "Frappé",
            "dark": true,
            "crust": "#232634", "mantle": "#292c3c", "base": "#303446",
            "surface0": "#414559", "surface1": "#51576d", "surface2": "#626880",
            "overlay0": "#737994", "overlay1": "#838ba7", "overlay2": "#949cbb",
            "subtext0": "#a5adce", "subtext1": "#b5bfe2", "text": "#c6d0f5",
            "rosewater": "#f2d5cf", "flamingo": "#eebebe", "pink": "#f4b8e4", "mauve": "#ca9ee6",
            "red": "#e78284", "maroon": "#ea999c", "peach": "#ef9f76", "yellow": "#e5c890",
            "green": "#a6d189", "teal": "#81c8be", "sky": "#99d1db", "sapphire": "#85c1dc",
            "blue": "#8caaee", "lavender": "#babbf1"
        },
        "latte": {
            "name": "Latte",
            "dark": false,
            "crust": "#dce0e8", "mantle": "#e6e9ef", "base": "#eff1f5",
            "surface0": "#ccd0da", "surface1": "#bcc0cc", "surface2": "#acb0be",
            "overlay0": "#9ca0b0", "overlay1": "#8c8fa1", "overlay2": "#7c7f93",
            "subtext0": "#6c6f85", "subtext1": "#5c5f77", "text": "#4c4f69",
            "rosewater": "#dc8a78", "flamingo": "#dd7878", "pink": "#ea76cb", "mauve": "#8839ef",
            "red": "#d20f39", "maroon": "#e64553", "peach": "#fe640b", "yellow": "#df8e1d",
            "green": "#40a02b", "teal": "#179299", "sky": "#04a5e5", "sapphire": "#209fb5",
            "blue": "#1e66f5", "lavender": "#7287fd"
        }
    })

    readonly property var flavorOrder: ["mocha", "macchiato", "frappe", "latte"]
    readonly property var accentNames: ["mauve", "lavender", "blue", "sky", "teal", "green", "yellow", "peach", "pink", "rosewater"]

    // ─── Текущее состояние ──────────────────────────────────────────────────
    property string flavor: "mocha"
    property string accentName: "mauve"

    readonly property var p: palettes[flavor] ?? palettes["mocha"]
    readonly property bool isDark: p.dark
    readonly property string flavorLabel: p.name

    // ─── Базовые цвета ──────────────────────────────────────────────────────
    readonly property color crust: p.crust
    readonly property color mantle: p.mantle
    readonly property color base: p.base
    readonly property color surface0: p.surface0
    readonly property color surface1: p.surface1
    readonly property color surface2: p.surface2
    readonly property color overlay0: p.overlay0
    readonly property color overlay1: p.overlay1
    readonly property color overlay2: p.overlay2
    readonly property color subtext0: p.subtext0
    readonly property color subtext1: p.subtext1
    readonly property color text: p.text

    readonly property color rosewater: p.rosewater
    readonly property color flamingo: p.flamingo
    readonly property color pink: p.pink
    readonly property color mauve: p.mauve
    readonly property color red: p.red
    readonly property color maroon: p.maroon
    readonly property color peach: p.peach
    readonly property color yellow: p.yellow
    readonly property color green: p.green
    readonly property color teal: p.teal
    readonly property color sky: p.sky
    readonly property color sapphire: p.sapphire
    readonly property color blue: p.blue
    readonly property color lavender: p.lavender

    readonly property color accent: p[accentName] ?? p.mauve

    // ─── Семантические цвета ────────────────────────────────────────────────
    readonly property color barBg: alpha(mantle, 0.92)          // фон панели
    readonly property color trayBg: alpha(crust, isDark ? 0.75 : 0.55) // «затемнённый» блок системного трея
    readonly property color popupBg: isDark ? mantle : base     // фон док-окна
    readonly property color popupBorder: alpha(surface1, 0.7)
    readonly property color hoverBg: alpha(surface0, 0.75)
    readonly property color pressBg: alpha(surface1, 0.85)
    readonly property color trackBg: alpha(surface0, isDark ? 0.9 : 1.0)
    readonly property color separator: alpha(surface1, 0.5)
    readonly property color shadow: alpha(crust, isDark ? 0.55 : 0.25)

    // ─── Утилиты ────────────────────────────────────────────────────────────
    function alpha(c: color, a: real): color {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    // Цвет нагрузки: спокойный → тёплый по мере роста значения (0..100)
    function loadColor(v: real): color {
        if (v >= 90)
            return red;
        if (v >= 75)
            return peach;
        if (v >= 50)
            return yellow;
        return green;
    }

    function setFlavor(name: string): void {
        if (!palettes[name])
            return;
        root.flavor = name;
        persist.flavor = name;
        stateFile.writeAdapter();
    }

    function setAccent(name: string): void {
        root.accentName = name;
        persist.accent = name;
        stateFile.writeAdapter();
    }

    function toggleMode(): void {
        setFlavor(isDark ? "latte" : "mocha");
    }

    function cycleFlavor(): void {
        const i = flavorOrder.indexOf(flavor);
        setFlavor(flavorOrder[(i + 1) % flavorOrder.length]);
    }

    // ─── Сохранение выбора между запусками ──────────────────────────────────
    property bool _restored: false

    FileView {
        id: stateFile

        // Без watchChanges: перечитывание после нашей же записи гоняется с ней
        // и может откатить только что выбранную тему.
        path: Quickshell.statePath("theme.json")
        onLoadFailed: writeAdapter()
        onLoaded: {
            if (root._restored)
                return;
            root._restored = true;
            if (root.palettes[persist.flavor])
                root.flavor = persist.flavor;
            if (persist.accent)
                root.accentName = persist.accent;
        }

        JsonAdapter {
            id: persist

            property string flavor: "mocha"
            property string accent: "mauve"
        }
    }
}
