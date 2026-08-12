import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

//
// Компактный индикатор: иконка, значение и тонкая полоса загрузки.
//
Item {
    id: root

    property string icon: ""
    property real value: 0            // 0..100
    property color accent: Theme.blue
    property string valueText: `${Math.round(value)}%`
    property bool colorByLoad: false

    readonly property color currentColor: colorByLoad ? Theme.loadColor(value) : accent

    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight

    Column {
        id: column

        anchors.centerIn: parent
        spacing: 2

        Row {
            id: row

            spacing: Appearance.spacing.small

            MaterialIcon {
                anchors.verticalCenter: parent.verticalCenter
                text: root.icon
                color: root.currentColor
                fill: root.value > 80 ? 1 : 0
                font.pixelSize: Appearance.font.icon.small
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: root.valueText
                color: Theme.text
                mono: true
                font.pixelSize: Appearance.font.size.small
                font.weight: Font.DemiBold
            }
        }

        Rectangle {
            width: Math.max(row.implicitWidth, Appearance.px(42))
            height: Appearance.px(3)
            radius: height / 2
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
}
