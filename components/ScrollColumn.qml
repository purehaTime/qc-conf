import QtQuick
import QtQuick.Layouts
import qs.config

//
// Прокручиваемая колонка с ограничением по высоте и тонким индикатором.
//
Item {
    id: root

    property int maxHeight: 280      // «при масштабе 100 %»
    property int spacing: 2

    default property alias content: column.data

    Layout.fillWidth: true
    implicitHeight: Math.min(Appearance.px(maxHeight), column.implicitHeight)

    Flickable {
        id: flick

        anchors.fill: parent
        contentHeight: column.implicitHeight
        contentWidth: width
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickDeceleration: 4000

        ColumnLayout {
            id: column

            width: flick.width
            spacing: root.spacing
        }
    }

    Rectangle {
        anchors.right: parent.right
        width: Appearance.px(3)
        radius: width / 2
        color: Theme.overlay0
        visible: flick.contentHeight > flick.height
        opacity: flick.moving ? 0.7 : 0.25
        y: flick.contentHeight > 0 ? flick.contentY * root.height / flick.contentHeight : 0
        height: flick.contentHeight > 0 ? Math.max(Appearance.px(24), root.height * root.height / flick.contentHeight) : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.anim.normal
            }
        }
    }
}
