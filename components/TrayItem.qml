import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services

//
// Кнопка системного трея: иконка/подпись, подсказка при наведении
// и док-окно с настройками при клике. Содержимое попапа — дети элемента.
//
Item {
    id: root

    required property string popupId
    property string icon: ""
    property string label: ""
    property color iconColor: Theme.text
    property real iconFill: 0
    property int iconSize: Appearance.font.icon.normal
    property string tooltipText: ""
    property string tooltipSubtext: ""
    property int popupWidth: 320
    property int popupAlignment: Qt.AlignHCenter
    property bool indicator: false
    property color indicatorColor: Theme.green
    property bool clickOpensPopup: true

    readonly property bool popupOpen: Popups.isOpen(popupId)
    readonly property bool hovered: button.hovered

    default property alias popupContent: popup.cardData

    signal clicked
    signal rightClicked
    signal middleClicked
    signal wheelUp
    signal wheelDown

    implicitWidth: button.implicitWidth
    implicitHeight: Appearance.bar.itemHeight

    function togglePopup(): void {
        Popups.toggle(popupId);
    }

    // Через Connections, чтобы обработчик не перекрывался при использовании типа
    Connections {
        target: root

        function onPopupOpenChanged(): void {
            if (root.popupOpen) {
                tooltipTimer.stop();
                tooltip.shown = false;
            } else {
                closeTimer.stop();
            }
        }
    }

    BarButton {
        id: button

        anchors.centerIn: parent
        implicitWidth: content.implicitWidth + Appearance.padding.normal * 2
        implicitHeight: Appearance.bar.itemHeight
        active: root.popupOpen
        activeColor: Theme.alpha(root.iconColor, 0.18)

        onClicked: {
            root.clicked();
            if (root.clickOpensPopup)
                root.togglePopup();
        }
        onRightClicked: root.rightClicked()
        onMiddleClicked: root.middleClicked()
        onWheelUp: root.wheelUp()
        onWheelDown: root.wheelDown()

        RowLayout {
            id: content

            anchors.centerIn: parent
            spacing: Appearance.spacing.small

            MaterialIcon {
                visible: root.icon.length > 0
                text: root.icon
                color: root.iconColor
                fill: root.popupOpen ? 1 : root.iconFill
                font.pixelSize: root.iconSize
            }

            StyledText {
                visible: root.label.length > 0
                text: root.label
                color: root.iconColor
                font.pixelSize: Appearance.font.size.small
                font.weight: Font.DemiBold
            }
        }

        Rectangle {
            visible: root.indicator
            width: Appearance.px(5)
            height: Appearance.px(5)
            radius: width / 2
            color: root.indicatorColor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 1

            Behavior on color {
                ColorAnimation {
                    duration: Appearance.anim.normal
                }
            }
        }
    }

    // ─── Подсказка ──────────────────────────────────────────────────────────
    Timer {
        id: tooltipTimer

        interval: 320
        onTriggered: tooltip.shown = true
    }

    Connections {
        target: button

        function onHoveredChanged(): void {
            if (button.hovered && root.tooltipText.length > 0 && !root.popupOpen)
                tooltipTimer.restart();
            else {
                tooltipTimer.stop();
                tooltip.shown = false;
            }
        }
    }

    Tooltip {
        id: tooltip

        anchorItem: root
        text: root.tooltipText
        subtext: root.tooltipSubtext
    }

    // ─── Док-окно ───────────────────────────────────────────────────────────
    DockPopup {
        id: popup

        anchorItem: root
        popupId: root.popupId
        cardWidth: root.popupWidth
        alignment: root.popupAlignment
    }

    readonly property bool anyHovered: button.hovered || popup.hovered

    Connections {
        target: root

        function onAnyHoveredChanged(): void {
            if (root.anyHovered)
                closeTimer.stop();
            else if (root.popupOpen)
                closeTimer.restart();
        }
    }

    Timer {
        id: closeTimer

        interval: 700
        onTriggered: if (!root.anyHovered)
            Popups.close(root.popupId)
    }
}
