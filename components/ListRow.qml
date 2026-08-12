import QtQuick
import QtQuick.Layouts
import qs.config

//
// Строка списка: иконка, заголовок с подписью, произвольный хвост справа.
//
Rectangle {
    id: root

    property string icon: ""
    property color iconColor: Theme.subtext1
    property real iconFill: 0
    property string title: ""
    property string subtitle: ""
    property bool active: false
    property bool busy: false
    property color accent: Theme.accent

    readonly property alias hovered: mouse.containsMouse

    signal clicked
    signal rightClicked

    default property alias trailing: trailingItem.data

    Layout.fillWidth: true
    implicitHeight: Math.max(36, row.implicitHeight + Appearance.padding.small * 2)
    radius: Appearance.radius.normal
    color: mouse.pressed ? Theme.pressBg : (mouse.containsMouse ? Theme.hoverBg : (active ? Theme.alpha(accent, 0.14) : "transparent"))

    Behavior on color {
        ColorAnimation {
            duration: Appearance.anim.fast
        }
    }

    // Объявлен раньше содержимого, чтобы интерактивные элементы справа
    // (переключатели, кнопки) получали клики первыми.
    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            if (event.button === Qt.RightButton)
                root.rightClicked();
            else
                root.clicked();
        }
    }

    RowLayout {
        id: row

        anchors.fill: parent
        anchors.leftMargin: Appearance.padding.small
        anchors.rightMargin: Appearance.padding.small
        spacing: Appearance.spacing.normal

        MaterialIcon {
            visible: root.icon.length > 0
            text: root.icon
            color: root.active ? root.accent : root.iconColor
            fill: root.active ? 1 : root.iconFill
            font.pixelSize: Appearance.font.icon.normal

            RotationAnimator on rotation {
                running: root.busy
                loops: Animation.Infinite
                from: 0
                to: 360
                duration: 1400
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            StyledText {
                Layout.fillWidth: true
                text: root.title
                color: root.active ? root.accent : Theme.text
                font.pixelSize: Appearance.font.size.normal
                font.weight: root.active ? Font.DemiBold : Font.Normal
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                visible: root.subtitle.length > 0
                text: root.subtitle
                color: Theme.subtext0
                font.pixelSize: Appearance.font.size.tiny
                elide: Text.ElideRight
            }
        }

        Item {
            id: trailingItem

            Layout.alignment: Qt.AlignVCenter
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }
    }
}
