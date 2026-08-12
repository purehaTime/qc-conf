import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components

//
// Звук: громкость вывода/ввода и выбор устройств.
//
TrayItem {
    id: root

    popupId: "volume"
    icon: Audio.icon
    iconColor: Audio.muted ? Theme.red : Theme.sky
    iconFill: Audio.muted ? 1 : 0
    popupWidth: 330
    tooltipText: Audio.muted ? "Звук выключен" : `Громкость ${Audio.volumePercent}%`
    tooltipSubtext: Audio.sinkName

    onWheelUp: Audio.changeVolume(Settings.volumeStep)
    onWheelDown: Audio.changeVolume(-Settings.volumeStep)
    onMiddleClicked: Audio.toggleMute()
    onRightClicked: Quickshell.execDetached(["sh", "-c", Settings.audioSettings])

    // ─── Вывод ──────────────────────────────────────────────────────────────
    SectionLabel {
        text: "Вывод"
        icon: "volume_up"
        accent: Theme.sky
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.normal

        BarButton {
            implicitWidth: Appearance.px(30)
            implicitHeight: Appearance.px(30)
            radius: Appearance.radius.full
            onClicked: Audio.toggleMute()

            MaterialIcon {
                anchors.centerIn: parent
                text: Audio.icon
                color: Audio.muted ? Theme.red : Theme.sky
                fill: Audio.muted ? 1 : 0
                font.pixelSize: Appearance.font.icon.normal
            }
        }

        PastelSlider {
            Layout.fillWidth: true
            accent: Audio.muted ? Theme.overlay0 : Theme.sky
            value: Audio.volume / Settings.volumeMax
            onMoved: v => Audio.setVolume(v * Settings.volumeMax)
        }

        StyledText {
            Layout.preferredWidth: Appearance.px(34)
            horizontalAlignment: Text.AlignRight
            text: `${Audio.volumePercent}%`
            color: Theme.subtext0
            mono: true
            font.pixelSize: Appearance.font.size.small
        }
    }

    // ─── Ввод ───────────────────────────────────────────────────────────────
    SectionLabel {
        visible: Audio.source !== null
        text: "Микрофон"
        icon: "mic"
        accent: Theme.green
    }

    RowLayout {
        Layout.fillWidth: true
        visible: Audio.source !== null
        spacing: Appearance.spacing.normal

        BarButton {
            implicitWidth: Appearance.px(30)
            implicitHeight: Appearance.px(30)
            radius: Appearance.radius.full
            onClicked: Audio.toggleInputMute()

            MaterialIcon {
                anchors.centerIn: parent
                text: Audio.inputMuted ? "mic_off" : "mic"
                color: Audio.inputMuted ? Theme.red : Theme.green
                fill: Audio.inputMuted ? 1 : 0
                font.pixelSize: Appearance.font.icon.normal
            }
        }

        PastelSlider {
            Layout.fillWidth: true
            accent: Audio.inputMuted ? Theme.overlay0 : Theme.green
            value: Audio.inputVolume
            onMoved: v => Audio.setInputVolume(v)
        }

        StyledText {
            Layout.preferredWidth: Appearance.px(34)
            horizontalAlignment: Text.AlignRight
            text: `${Audio.inputVolumePercent}%`
            color: Theme.subtext0
            mono: true
            font.pixelSize: Appearance.font.size.small
        }
    }

    // ─── Устройства вывода ──────────────────────────────────────────────────
    SectionLabel {
        visible: Audio.sinks.length > 1
        text: "Устройства"
        icon: "speaker"
        accent: Theme.sky
    }

    ScrollColumn {
        maxHeight: 180
        visible: Audio.sinks.length > 1

        Repeater {
            model: Audio.sinks

            ListRow {
                required property var modelData

                title: Audio.nodeLabel(modelData)
                icon: modelData === Audio.sink ? "check_circle" : "speaker"
                accent: Theme.sky
                active: modelData === Audio.sink
                onClicked: Audio.setDefaultSink(modelData)
            }
        }
    }
}
