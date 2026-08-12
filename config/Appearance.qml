pragma Singleton

//
// Размеры, шрифты, скругления, анимации. Всё «мягкое»: крупные радиусы,
// умеренные тени, короткие плавные переходы.
//
// Все кегли и высоты проходят через fontScale — его можно менять на лету
// в док-окне темы; значение сохраняется между запусками.
//

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // ─── Масштаб шрифта ─────────────────────────────────────────────────────
    property real fontScale: 1.0

    readonly property real minFontScale: 0.75
    readonly property real maxFontScale: 1.6
    readonly property real fontScaleStep: 0.05

    // Попапы растут медленнее текста, иначе на крупном кегле они огромные
    readonly property real popupScale: 1 + (fontScale - 1) * 0.7

    // производные readonly-значения для UI
    readonly property int fontScalePercent: Math.round(fontScale * 100)
    readonly property real fontScaleNormalized: (fontScale - minFontScale) / (maxFontScale - minFontScale)

    function scaled(value: real): int {
        return Math.max(1, Math.round(value * root.fontScale));
    }

    function setFontScale(value: real): void {
        const snapped = Math.round(value / fontScaleStep) * fontScaleStep;
        const clamped = Math.max(minFontScale, Math.min(maxFontScale, snapped));
        root.fontScale = clamped;
        persist.fontScale = clamped;
        stateFile.writeAdapter();
    }

    function changeFontScale(delta: real): void {
        setFontScale(root.fontScale + delta);
    }

    function resetFontScale(): void {
        setFontScale(1.0);
    }

    // ─── Шрифты ─────────────────────────────────────────────────────────────
    readonly property QtObject font: QtObject {
        readonly property string family: "Adwaita Sans"     // основной интерфейсный
        readonly property string mono: "JetBrainsMono Nerd Font" // цифры/метрики
        readonly property string icons: "Material Symbols Rounded"

        readonly property QtObject size: QtObject {
            readonly property int tiny: root.scaled(10)
            readonly property int small: root.scaled(11)
            readonly property int normal: root.scaled(12)
            readonly property int medium: root.scaled(13)
            readonly property int large: root.scaled(15)
            readonly property int huge: root.scaled(18)
        }

        readonly property QtObject icon: QtObject {
            readonly property int small: root.scaled(14)
            readonly property int normal: root.scaled(17)
            readonly property int large: root.scaled(20)
            readonly property int huge: root.scaled(26)
        }
    }

    readonly property QtObject radius: QtObject {
        readonly property int small: 8
        readonly property int normal: 12
        readonly property int large: 16
        readonly property int huge: 22
        readonly property int full: 999
    }

    readonly property QtObject spacing: QtObject {
        readonly property int tiny: 2
        readonly property int small: 4
        readonly property int normal: 8
        readonly property int medium: 12
        readonly property int large: 16
        readonly property int huge: 24
    }

    readonly property QtObject padding: QtObject {
        readonly property int tiny: 2
        readonly property int small: 6
        readonly property int normal: 10
        readonly property int medium: 14
        readonly property int large: 18
    }

    readonly property QtObject bar: QtObject {
        // Высота панели тянется за кеглем, но мягче: 1.0 → 38, 1.3 → 43
        readonly property int height: Math.round(20 + 18 * root.fontScale)
        readonly property int itemHeight: Math.round(12 + 16 * root.fontScale)
        readonly property int itemWidth: root.scaled(32)
        readonly property int sideMargin: 8
        readonly property int popupGap: 8
    }

    readonly property QtObject anim: QtObject {
        readonly property int fast: 110
        readonly property int normal: 180
        readonly property int slow: 300
        readonly property int curve: Easing.OutQuint
        readonly property int curveEmphasized: Easing.OutBack
    }

    // ─── Сохранение масштаба между запусками ────────────────────────────────
    property bool _restored: false

    FileView {
        id: stateFile

        // Без watchChanges: файл пишем только мы, а перечитывание гонялось бы
        // с записью и откатывало только что выбранное значение.
        path: Quickshell.statePath("appearance.json")
        onLoadFailed: writeAdapter()
        onLoaded: {
            if (root._restored)
                return;
            root._restored = true;
            if (persist.fontScale > 0)
                root.fontScale = Math.max(root.minFontScale, Math.min(root.maxFontScale, persist.fontScale));
        }

        JsonAdapter {
            id: persist

            property real fontScale: 1.0
        }
    }
}
