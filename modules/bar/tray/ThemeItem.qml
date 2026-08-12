import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components

//
// Смена темы: вариант Catppuccin и акцентный цвет.
//
TrayItem {
    id: root

    popupId: "theme"
    icon: Theme.isDark ? "dark_mode" : "light_mode"
    iconColor: Theme.accent
    popupWidth: 300
    tooltipText: `Тема: ${Theme.flavorLabel}`
    tooltipSubtext: "Колесо — сменить вариант"

    onWheelUp: Theme.cycleFlavor()
    onWheelDown: Theme.cycleFlavor()
    onMiddleClicked: Theme.toggleMode()

    SectionLabel {
        text: "Оформление"
        icon: "palette"
        accent: Theme.accent
    }

    // ─── Варианты ───────────────────────────────────────────────────────────
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        columnSpacing: Appearance.spacing.normal
        rowSpacing: Appearance.spacing.normal

        Repeater {
            model: Theme.flavorOrder

            BarButton {
                required property var modelData

                readonly property var flavorPalette: Theme.palettes[modelData]
                readonly property bool selected: Theme.flavor === modelData

                Layout.fillWidth: true
                implicitHeight: 46
                radius: Appearance.radius.normal
                baseColor: flavorPalette.base
                activeColor: flavorPalette.base
                border.width: selected ? 2 : 1
                border.color: selected ? Theme.accent : Theme.alpha(Theme.overlay0, 0.4)
                onClicked: Theme.setFlavor(modelData)

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Appearance.spacing.normal

                    Row {
                        spacing: 3

                        Repeater {
                            model: ["mauve", "blue", "green", "peach"]

                            Rectangle {
                                required property var modelData

                                width: 8
                                height: 8
                                radius: 4
                                color: flavorPalette[modelData]
                            }
                        }
                    }

                    StyledText {
                        text: flavorPalette.name
                        color: flavorPalette.text
                        font.pixelSize: Appearance.font.size.small
                        font.weight: selected ? Font.DemiBold : Font.Normal
                    }
                }
            }
        }
    }

    // ─── Акцент ─────────────────────────────────────────────────────────────
    SectionLabel {
        text: "Акцент"
        icon: "colorize"
        accent: Theme.accent
    }

    Flow {
        Layout.fillWidth: true
        spacing: Appearance.spacing.normal

        Repeater {
            model: Theme.accentNames

            Rectangle {
                required property var modelData

                readonly property bool selected: Theme.accentName === modelData

                width: 26
                height: 26
                radius: 13
                color: Theme.p[modelData]
                border.width: selected ? 3 : 0
                border.color: Theme.text
                scale: mouse.containsMouse ? 1.12 : 1

                Behavior on scale {
                    NumberAnimation {
                        duration: Appearance.anim.fast
                    }
                }

                MouseArea {
                    id: mouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Theme.setAccent(modelData)
                }
            }
        }
    }

    // ─── Размер шрифта ──────────────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small

        SectionLabel {
            text: "Размер шрифта"
            icon: "format_size"
            accent: Theme.accent
        }

        BarButton {
            implicitWidth: 24
            implicitHeight: 24
            radius: Appearance.radius.full
            visible: Appearance.fontScalePercent !== 100
            onClicked: Appearance.resetFontScale()

            MaterialIcon {
                anchors.centerIn: parent
                text: "restart_alt"
                color: Theme.subtext0
                font.pixelSize: Appearance.font.icon.small
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.normal

        BarButton {
            implicitWidth: 28
            implicitHeight: 28
            radius: Appearance.radius.full
            enabled: Appearance.fontScale > Appearance.minFontScale
            onClicked: Appearance.changeFontScale(-Appearance.fontScaleStep)

            MaterialIcon {
                anchors.centerIn: parent
                text: "text_decrease"
                color: Theme.subtext1
                font.pixelSize: Appearance.font.icon.small
            }
        }

        PastelSlider {
            Layout.fillWidth: true
            accent: Theme.accent
            value: Appearance.fontScaleNormalized
            onMoved: v => Appearance.setFontScale(Appearance.minFontScale + v * (Appearance.maxFontScale - Appearance.minFontScale))
        }

        BarButton {
            implicitWidth: 28
            implicitHeight: 28
            radius: Appearance.radius.full
            enabled: Appearance.fontScale < Appearance.maxFontScale
            onClicked: Appearance.changeFontScale(Appearance.fontScaleStep)

            MaterialIcon {
                anchors.centerIn: parent
                text: "text_increase"
                color: Theme.subtext1
                font.pixelSize: Appearance.font.icon.normal
            }
        }

        StyledText {
            Layout.preferredWidth: 42
            horizontalAlignment: Text.AlignRight
            text: `${Appearance.fontScalePercent}%`
            color: Theme.subtext0
            mono: true
            font.pixelSize: Appearance.font.size.small
        }
    }

    // ─── Быстрый переключатель светлая/тёмная ───────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.normal

        MaterialIcon {
            text: Theme.isDark ? "dark_mode" : "light_mode"
            color: Theme.accent
            fill: 1
            font.pixelSize: Appearance.font.icon.small
        }

        StyledText {
            Layout.fillWidth: true
            text: Theme.isDark ? "Тёмная тема" : "Светлая тема"
            color: Theme.text
            font.pixelSize: Appearance.font.size.small
        }

        ToggleSwitch {
            checked: !Theme.isDark
            accent: Theme.accent
            onToggled: Theme.toggleMode()
        }
    }
}
