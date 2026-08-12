import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components

//
// Яркость мониторов (backlight или DDC/CI).
//
TrayItem {
    id: root

    popupId: "brightness"
    icon: Brightness.icon
    iconColor: Theme.yellow
    popupWidth: 320
    tooltipText: Brightness.available ? `Яркость ${Brightness.percent}%` : "Яркость недоступна"
    tooltipSubtext: Brightness.available ? (Brightness.primary?.label ?? "") : "нет backlight / ddcutil"

    onWheelUp: Brightness.change(0, Settings.brightnessStep)
    onWheelDown: Brightness.change(0, -Settings.brightnessStep)

    RowLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small

        SectionLabel {
            text: "Яркость"
            icon: "brightness_6"
            accent: Theme.yellow
        }

        BarButton {
            implicitWidth: Appearance.px(26)
            implicitHeight: Appearance.px(26)
            radius: Appearance.radius.full
            enabled: !Brightness.probing
            onClicked: Brightness.refresh()

            MaterialIcon {
                anchors.centerIn: parent
                text: "refresh"
                color: Theme.subtext1
                font.pixelSize: Appearance.font.icon.small

                RotationAnimator on rotation {
                    running: Brightness.probing
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: 1200
                }
            }
        }
    }

    Repeater {
        model: Brightness.devices

        ColumnLayout {
            required property int index
            required property var modelData

            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    Layout.fillWidth: true
                    text: modelData.label
                    color: Theme.subtext1
                    font.pixelSize: Appearance.font.size.small
                    elide: Text.ElideRight
                }

                StyledText {
                    text: `${Math.round(modelData.value)}%`
                    color: Theme.subtext0
                    mono: true
                    font.pixelSize: Appearance.font.size.small
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.normal

                MaterialIcon {
                    text: "brightness_low"
                    color: Theme.overlay1
                    font.pixelSize: Appearance.font.icon.small
                }

                PastelSlider {
                    Layout.fillWidth: true
                    accent: Theme.yellow
                    value: modelData.value / 100
                    onMoved: v => Brightness.setValue(index, v * 100)
                }

                MaterialIcon {
                    text: "brightness_high"
                    color: Theme.overlay1
                    font.pixelSize: Appearance.font.icon.small
                }
            }
        }
    }

    StyledText {
        Layout.fillWidth: true
        visible: !Brightness.available
        text: Brightness.probing ? "Поиск мониторов…" : "Управление яркостью недоступно"
        color: Theme.overlay1
        font.pixelSize: Appearance.font.size.small
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }

    StyledText {
        Layout.fillWidth: true
        visible: !Brightness.available && Brightness.probed
        text: "Нужен /sys/class/backlight или ddcutil с доступом к i2c"
        color: Theme.overlay0
        font.pixelSize: Appearance.font.size.tiny
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }
}
