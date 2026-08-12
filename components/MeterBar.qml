import QtQuick
import QtQuick.Layouts
import qs.config

//
// Строка «иконка + подпись + значение» с полосой заполнения.
//
ColumnLayout {
    id: root

    property string icon: ""
    property string label: ""
    property string valueText: ""
    property real value: 0            // 0..100
    property color accent: Theme.accent
    property bool colorByLoad: false

    readonly property color currentColor: colorByLoad ? Theme.loadColor(value) : accent

    Layout.fillWidth: true
    spacing: 4

    RowLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.normal

        MaterialIcon {
            visible: root.icon.length > 0
            text: root.icon
            color: root.currentColor
            font.pixelSize: Appearance.font.icon.small
        }

        StyledText {
            text: root.label
            color: Theme.text
            font.pixelSize: Appearance.font.size.normal
        }

        Item {
            Layout.fillWidth: true
        }

        StyledText {
            text: root.valueText
            color: Theme.subtext0
            mono: true
            font.pixelSize: Appearance.font.size.small
        }
    }

    Rectangle {
        Layout.fillWidth: true
        height: 8
        radius: 4
        color: Theme.trackBg

        Rectangle {
            width: parent.width * Math.max(0, Math.min(100, root.value)) / 100
            height: parent.height
            radius: parent.radius
            color: root.currentColor

            Behavior on width {
                NumberAnimation {
                    duration: Appearance.anim.slow
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Appearance.anim.slow
                }
            }
        }
    }
}
