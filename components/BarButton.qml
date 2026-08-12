import QtQuick
import qs.config

Rectangle {
    id: root

    property bool active: false
    property color baseColor: "transparent"
    property color activeColor: Theme.alpha(Theme.accent, 0.18)
    property bool pressFeedback: true

    readonly property alias hovered: mouse.containsMouse
    readonly property alias pressed: mouse.pressed

    signal clicked
    signal rightClicked
    signal middleClicked
    signal wheelUp
    signal wheelDown

    default property alias contentData: contentItem.data

    implicitWidth: Appearance.bar.itemWidth
    implicitHeight: Appearance.bar.itemHeight
    radius: Appearance.radius.normal
    color: mouse.pressed ? Theme.pressBg : (mouse.containsMouse ? Theme.hoverBg : (active ? activeColor : baseColor))
    opacity: enabled ? 1 : 0.4
    scale: pressFeedback && mouse.pressed ? 0.93 : 1

    Behavior on color {
        ColorAnimation {
            duration: Appearance.anim.fast
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.anim.fast
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Appearance.anim.fast
            easing.type: Easing.OutQuad
        }
    }

    Item {
        id: contentItem

        anchors.fill: parent
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: event => {
            if (event.button === Qt.RightButton)
                root.rightClicked();
            else if (event.button === Qt.MiddleButton)
                root.middleClicked();
            else
                root.clicked();
        }

        onWheel: event => {
            if (event.angleDelta.y > 0)
                root.wheelUp();
            else if (event.angleDelta.y < 0)
                root.wheelDown();
        }
    }
}
