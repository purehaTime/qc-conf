pragma Singleton

//
// Размеры, шрифты, скругления, анимации. Всё «мягкое»: крупные радиусы,
// умеренные тени, короткие плавные переходы.
//
// Все размеры проходят через px() — общий масштаб панели задаётся одной
// константой Settings.scale (см. config/Settings.qml).
//

import Quickshell
import QtQuick

Singleton {
    id: root

    // Общий масштаб панели: 1.0 — базовый
    readonly property real scale: Settings.scale

    // Размер в пикселях с учётом масштаба
    function px(value: real): int {
        return Math.max(1, Math.round(value * root.scale));
    }

    // ─── Шрифты ─────────────────────────────────────────────────────────────
    readonly property QtObject font: QtObject {
        readonly property string family: "Adwaita Sans"     // основной интерфейсный
        readonly property string mono: "JetBrainsMono Nerd Font" // цифры/метрики
        readonly property string icons: "Material Symbols Rounded"

        readonly property QtObject size: QtObject {
            readonly property int tiny: root.px(10)
            readonly property int small: root.px(11)
            readonly property int normal: root.px(12)
            readonly property int medium: root.px(13)
            readonly property int large: root.px(15)
            readonly property int huge: root.px(18)
        }

        readonly property QtObject icon: QtObject {
            readonly property int small: root.px(14)
            readonly property int normal: root.px(17)
            readonly property int large: root.px(20)
            readonly property int huge: root.px(26)
        }
    }

    readonly property QtObject radius: QtObject {
        readonly property int small: root.px(8)
        readonly property int normal: root.px(12)
        readonly property int large: root.px(16)
        readonly property int huge: root.px(22)
        readonly property int full: 999
    }

    readonly property QtObject spacing: QtObject {
        readonly property int tiny: root.px(2)
        readonly property int small: root.px(4)
        readonly property int normal: root.px(8)
        readonly property int medium: root.px(12)
        readonly property int large: root.px(16)
        readonly property int huge: root.px(24)
    }

    readonly property QtObject padding: QtObject {
        readonly property int tiny: root.px(2)
        readonly property int small: root.px(6)
        readonly property int normal: root.px(10)
        readonly property int medium: root.px(14)
        readonly property int large: root.px(18)
    }

    readonly property QtObject bar: QtObject {
        readonly property int height: root.px(38)
        readonly property int itemHeight: root.px(28)
        readonly property int itemWidth: root.px(32)
        readonly property int sideMargin: root.px(8)
        readonly property int popupGap: root.px(8)
    }

    readonly property QtObject anim: QtObject {
        readonly property int fast: 110
        readonly property int normal: 180
        readonly property int slow: 300
        readonly property int curve: Easing.OutQuint
        readonly property int curveEmphasized: Easing.OutBack
    }
}
