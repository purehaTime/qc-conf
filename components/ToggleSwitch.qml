import QtQuick
import qs.config

Item {
    id: root

    property bool checked: false
    property color accent: Theme.accent

    signal toggled

    implicitWidth: 38
    implicitHeight: 21

    Rectangle {
        id: bg

        anchors.fill: parent
        radius: height / 2
        color: root.checked ? root.accent : Theme.trackBg
        opacity: mouse.containsMouse ? 0.85 : 1

        Behavior on color {
            ColorAnimation {
                duration: Appearance.anim.normal
            }
        }
    }

    Rectangle {
        id: knob

        width: parent.height - 6
        height: width
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? parent.width - width - 3 : 3
        color: root.checked ? (Theme.isDark ? Theme.crust : Theme.base) : Theme.overlay1
        scale: mouse.pressed ? 0.88 : 1

        Behavior on x {
            NumberAnimation {
                duration: Appearance.anim.normal
                easing.type: Appearance.anim.curve
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: Appearance.anim.normal
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Appearance.anim.fast
            }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
