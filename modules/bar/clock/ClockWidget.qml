import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components

//
// Часы: HH:mm + дата. Клик открывает календарь.
//
Item {
    id: root

    readonly property string popupId: "clock"
    readonly property var locale: Settings.locale ? Qt.locale(Settings.locale) : Qt.locale()

    implicitWidth: button.implicitWidth
    implicitHeight: Appearance.bar.itemHeight

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    BarButton {
        id: button

        anchors.centerIn: parent
        implicitWidth: clockRow.implicitWidth + Appearance.padding.normal * 2
        implicitHeight: Appearance.bar.itemHeight
        active: Popups.isOpen(root.popupId)
        activeColor: Theme.alpha(Theme.lavender, 0.16)
        onClicked: Popups.toggle(root.popupId)

        RowLayout {
            id: clockRow

            anchors.centerIn: parent
            spacing: Appearance.spacing.normal

            StyledText {
                text: clock.date.toLocaleString(root.locale, Settings.clockFormat)
                color: Theme.text
                font.pixelSize: Appearance.font.size.medium
                font.weight: Font.DemiBold
            }

            StyledText {
                text: {
                    const s = clock.date.toLocaleString(root.locale, Settings.dateFormat);
                    return s.charAt(0).toUpperCase() + s.slice(1);
                }
                color: Theme.subtext0
                font.pixelSize: Appearance.font.size.small
            }
        }
    }

    Tooltip {
        anchorItem: root
        shown: button.hovered && !Popups.isOpen(root.popupId)
        text: clock.date.toLocaleDateString(root.locale, Locale.LongFormat)
        subtext: "Календарь — по клику"
    }

    CalendarPopup {
        anchorItem: root
        popupId: root.popupId
        alignment: Qt.AlignRight
        now: clock.date
    }
}
