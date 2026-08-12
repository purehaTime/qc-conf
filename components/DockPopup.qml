import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import qs.config
import qs.services

//
// Скруглённое док-окно с настройками, привязанное к элементу панели.
// Содержимое складывается в колонку.
//
PopupWindow {
    id: root

    property Item anchorItem: null
    property string popupId: ""
    property int cardWidth: 320
    property int cardPadding: Appearance.padding.medium
    property int gap: Appearance.bar.popupGap
    property int shadowMargin: 18
    property int alignment: Qt.AlignHCenter    // AlignLeft | AlignHCenter | AlignRight

    readonly property bool shown: Popups.isOpen(popupId)
    readonly property alias hovered: hoverHandler.hovered
    // cardWidth задаётся «при масштабе 100 %», реальная ширина тянется за кеглем
    readonly property int scaledWidth: Math.round(cardWidth * Appearance.popupScale)
    readonly property int cardHeight: column.implicitHeight + cardPadding * 2

    default property alias cardData: column.data

    anchor.item: anchorItem
    anchor.rect.x: {
        if (!anchorItem)
            return 0;
        if (alignment === Qt.AlignLeft)
            return -shadowMargin;
        if (alignment === Qt.AlignRight)
            return anchorItem.width - scaledWidth - shadowMargin;
        return (anchorItem.width - root.implicitWidth) / 2;
    }
    anchor.rect.y: anchorItem ? anchorItem.height + gap - shadowMargin : 0
    anchor.adjustment: PopupAdjustment.SlideX

    implicitWidth: scaledWidth + shadowMargin * 2
    implicitHeight: cardHeight + shadowMargin * 2
    color: "transparent"
    visible: (root.shown || card.opacity > 0.01) && !_remapping

    mask: Region {
        item: card
    }

    // ─── Обход залипания кадра при изменении размера ────────────────────────
    // Если открытое окно попапа меняет размер (сменился кегль, подгрузился
    // список), на некоторых композиторах его поверхность перестаёт получать
    // новые кадры и содержимое остаётся нарисованным по-старому. Лечится
    // пересозданием поверхности: прячем окно на пару кадров и показываем снова.
    // Отключается через Settings.popupRemapOnResize.
    property bool _remapping: false
    property bool _settled: false

    onShownChanged: {
        _settled = false;
        if (shown)
            settleDelay.restart();
    }

    onCardHeightChanged: _requestRemap()
    onScaledWidthChanged: _requestRemap()

    function _requestRemap(): void {
        if (Settings.popupRemapOnResize && shown && _settled)
            remapDelay.restart();
    }

    Timer {
        id: settleDelay

        interval: 450   // пока попап раскрывается, размер ещё «дышит»
        onTriggered: root._settled = true
    }

    Timer {
        id: remapDelay

        interval: 200   // дебаунс: при перетаскивании ползунка не мигаем на каждый шаг
        onTriggered: {
            root._remapping = true;
            remapBack.restart();
        }
    }

    Timer {
        id: remapBack

        interval: 32
        onTriggered: root._remapping = false
    }

    Rectangle {
        id: card

        x: root.shadowMargin
        y: root.shadowMargin + (root.shown ? 0 : -10)
        width: root.scaledWidth
        height: root.cardHeight
        radius: Appearance.radius.large
        color: Theme.popupBg
        border.width: 1
        border.color: Theme.popupBorder
        opacity: root.shown ? 1 : 0

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Theme.shadow
            shadowBlur: 1.0
            shadowVerticalOffset: 4
            shadowOpacity: 0.9
            autoPaddingEnabled: true
        }

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

        Behavior on color {
            ColorAnimation {
                duration: Appearance.anim.normal
            }
        }

        HoverHandler {
            id: hoverHandler
        }

        ColumnLayout {
            id: column

            anchors.fill: parent
            anchors.margins: root.cardPadding
            spacing: Appearance.spacing.normal
        }
    }
}
