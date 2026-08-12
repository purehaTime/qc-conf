pragma Singleton

//
// Пользовательские настройки поведения. Правится руками — quickshell
// перечитает конфиг автоматически.
//

import Quickshell
import QtQuick

Singleton {
    id: root

    // ─── Панель ─────────────────────────────────────────────────────────────
    // На каких мониторах показывать панель. Пустой список = на всех.
    readonly property var barScreens: []

    // ─── Попапы ─────────────────────────────────────────────────────────────
    // Обход залипания кадра при изменении размера открытого док-окна
    // (см. components/DockPopup.qml). Если под niri всё и так перерисовывается,
    // можно выключить — тогда попап не будет моргать при смене размера.
    readonly property bool popupRemapOnResize: true

    // ─── Плеер ──────────────────────────────────────────────────────────────
    // Максимальная ширина названия трека в панели, px.
    // Если текст шире — он превращается в бегущую строку.
    readonly property int mediaTextMaxWidth: 400
    readonly property real marqueeSpeed: 34        // px в секунду
    readonly property int marqueePause: 1600       // пауза перед прокруткой, мс
    readonly property int marqueeGap: 48           // разрыв между повторами текста, px

    // ─── Часы ───────────────────────────────────────────────────────────────
    readonly property string clockFormat: "HH:mm"
    readonly property string dateFormat: "ddd dd MMM"
    readonly property string locale: "ru_RU"       // "" = системная локаль

    // ─── Системные метрики ──────────────────────────────────────────────────
    readonly property int metricsInterval: 2000    // мс между опросами
    readonly property int processInterval: 4000    // мс между опросами топа процессов
    readonly property bool showCpuTemp: true
    readonly property bool showGpuTemp: true

    // ─── Звук ───────────────────────────────────────────────────────────────
    readonly property real volumeStep: 0.02        // шаг колеса мыши
    readonly property real volumeMax: 1.0          // 1.0 = 100%, можно 1.5 для перегрузки

    // ─── Яркость ────────────────────────────────────────────────────────────
    // "auto" — sysfs backlight (ноутбук), иначе ddcutil (внешние мониторы)
    readonly property string brightnessBackend: "auto"  // auto | backlight | ddcutil | none
    readonly property int brightnessStep: 5            // шаг колеса мыши, %

    // ─── Буфер обмена ───────────────────────────────────────────────────────
    readonly property int clipboardLimit: 60       // сколько записей показывать

    // ─── Внешние команды ────────────────────────────────────────────────────
    readonly property string terminal: "kitty"
    readonly property string audioSettings: "pavucontrol"
    readonly property string networkSettings: "nm-connection-editor"
    readonly property string bluetoothSettings: "blueman-manager"
}
