import Quickshell
import QtQuick
import qs.config

//
// Всплывающая подсказка под элементом панели.
//
PopupWindow {
    id: root

    property Item anchorItem: null
    property string text: ""
    property string subtext: ""
    property bool shown: false
    property int gap: Appearance.bar.popupGap

    readonly property int cardWidth: Math.max(column.implicitWidth + Appearance.padding.medium * 2, 40)
    readonly property int cardHeight: column.implicitHeight + Appearance.padding.small * 2

    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? (anchorItem.width - root.implicitWidth) / 2 : 0
    anchor.rect.y: anchorItem ? anchorItem.height + gap : 0
    anchor.adjustment: PopupAdjustment.SlideX

    implicitWidth: cardWidth
    implicitHeight: cardHeight + 6
    color: "transparent"
    visible: root.shown || card.opacity > 0.01

    Rectangle {
        id: card

        width: root.cardWidth
        height: root.cardHeight
        y: root.shown ? 6 : 0
        opacity: root.shown ? 1 : 0
        radius: Appearance.radius.normal
        color: Theme.popupBg
        border.width: 1
        border.color: Theme.popupBorder

        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.anim.fast
                easing.type: Appearance.anim.curve
            }
        }

        Behavior on y {
            NumberAnimation {
                duration: Appearance.anim.normal
                easing.type: Appearance.anim.curve
            }
        }

        Column {
            id: column

            anchors.centerIn: parent
            spacing: 1

            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.text
                color: Theme.text
                font.pixelSize: Appearance.font.size.small
                font.weight: Font.DemiBold
            }

            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: root.subtext.length > 0
                text: root.subtext
                color: Theme.subtext0
                font.pixelSize: Appearance.font.size.tiny
            }
        }
    }
}
