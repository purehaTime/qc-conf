import QtQuick
import qs.config

//
// Горизонтальный слайдер 0..1 с мягкой дорожкой.
//
Item {
    id: root

    property real value: 0
    property color accent: Theme.accent
    property int barHeight: 8
    property bool interactive: true

    signal moved(real value)
    signal released(real value)

    implicitWidth: 160
    implicitHeight: 20

    function _valueAt(x: real): real {
        return Math.max(0, Math.min(1, x / Math.max(1, track.width)));
    }

    Rectangle {
        id: track

        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: root.barHeight
        radius: height / 2
        color: Theme.trackBg

        Rectangle {
            width: Math.max(root.barHeight, root.value * parent.width)
            height: parent.height
            radius: height / 2
            color: root.accent
            opacity: root.interactive ? 1 : 0.45

            Behavior on width {
                enabled: !mouse.pressed

                NumberAnimation {
                    duration: Appearance.anim.fast
                    easing.type: Easing.OutQuad
                }
            }
        }
    }

    Rectangle {
        id: handle

        width: mouse.pressed ? 16 : (mouse.containsMouse ? 15 : 13)
        height: width
        radius: width / 2
        color: Theme.isDark ? Theme.text : Theme.base
        border.width: 2
        border.color: root.accent
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(track.width - width, root.value * track.width - width / 2))
        visible: root.interactive

        Behavior on width {
            NumberAnimation {
                duration: Appearance.anim.fast
            }
        }

        Behavior on x {
            enabled: !mouse.pressed

            NumberAnimation {
                duration: Appearance.anim.fast
                easing.type: Easing.OutQuad
            }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        anchors.margins: -4
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        preventStealing: true

        onPressed: event => root.moved(root._valueAt(event.x))
        onPositionChanged: event => {
            if (pressed)
                root.moved(root._valueAt(event.x));
        }
        onReleased: event => root.released(root._valueAt(event.x))
        onWheel: event => {
            const step = event.angleDelta.y > 0 ? 0.05 : -0.05;
            root.moved(Math.max(0, Math.min(1, root.value + step)));
        }
    }
}
