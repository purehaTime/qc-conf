import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components

//
// Подробности по системе + самые прожорливые процессы.
//
DockPopup {
    id: root

    cardWidth: 330

    SectionLabel {
        text: "Процессор"
        icon: "memory"
        accent: Theme.blue
    }

    MeterBar {
        icon: ""
        label: `${SysInfo.cpuCores} потоков`
        value: SysInfo.cpuUsage
        colorByLoad: true
        valueText: `${Math.round(SysInfo.cpuUsage)}%` + (SysInfo.cpuTempAvailable ? `  ·  ${Math.round(SysInfo.cpuTemp)}°C` : "")
    }

    SectionLabel {
        text: "Память"
        icon: "developer_board"
        accent: Theme.mauve
    }

    MeterBar {
        label: "ОЗУ"
        accent: Theme.mauve
        value: SysInfo.memUsage
        valueText: SysInfo.memText
    }

    MeterBar {
        visible: SysInfo.swapTotal > 0.1
        label: "Подкачка"
        accent: Theme.lavender
        value: SysInfo.swapUsage
        valueText: `${SysInfo.swapUsed.toFixed(1)} / ${SysInfo.swapTotal.toFixed(1)} ГиБ`
    }

    SectionLabel {
        visible: SysInfo.gpuAvailable
        text: "Видеокарта"
        icon: "monitor_heart"
        accent: Theme.teal
    }

    StyledText {
        Layout.fillWidth: true
        visible: SysInfo.gpuAvailable && SysInfo.gpuName.length > 0
        text: SysInfo.gpuName
        color: Theme.subtext0
        font.pixelSize: Appearance.font.size.tiny
        elide: Text.ElideRight
    }

    MeterBar {
        visible: SysInfo.gpuAvailable
        label: "Загрузка"
        accent: Theme.teal
        colorByLoad: true
        value: SysInfo.gpuUsage
        valueText: `${Math.round(SysInfo.gpuUsage)}%` + (SysInfo.gpuTempAvailable ? `  ·  ${Math.round(SysInfo.gpuTemp)}°C` : "")
    }

    MeterBar {
        visible: SysInfo.gpuAvailable && SysInfo.gpuMemTotal > 0
        label: "Видеопамять"
        accent: Theme.sky
        value: SysInfo.gpuMemTotal > 0 ? 100 * SysInfo.gpuMemUsed / SysInfo.gpuMemTotal : 0
        valueText: SysInfo.gpuMemText
    }

    SectionLabel {
        text: "Процессы"
        icon: "list"
        accent: Theme.peach
    }

    ColumnLayout {
        Layout.fillWidth: true
        // фиксируем высоту, чтобы окно не «прыгало» при первом обновлении списка
        Layout.minimumHeight: 6 * 17
        spacing: 1

        Repeater {
            model: SysInfo.topProcesses.slice(0, 6)

            RowLayout {
                required property var modelData

                Layout.fillWidth: true
                spacing: Appearance.spacing.normal

                StyledText {
                    Layout.fillWidth: true
                    text: modelData.name
                    color: Theme.subtext1
                    font.pixelSize: Appearance.font.size.small
                    elide: Text.ElideRight
                }

                StyledText {
                    text: `${modelData.cpu.toFixed(1)}%`
                    color: Theme.loadColor(modelData.cpu)
                    mono: true
                    font.pixelSize: Appearance.font.size.tiny
                }

                StyledText {
                    Layout.preferredWidth: 42
                    horizontalAlignment: Text.AlignRight
                    text: `${modelData.mem.toFixed(1)}%`
                    color: Theme.overlay2
                    mono: true
                    font.pixelSize: Appearance.font.size.tiny
                }
            }
        }
    }
}
