import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.config
import qs.components

//
// Календарь на месяц с переключением месяцев.
//
DockPopup {
    id: root

    property date now: new Date()
    property int viewMonth: now.getMonth()
    property int viewYear: now.getFullYear()

    readonly property var locale: Settings.locale ? Qt.locale(Settings.locale) : Qt.locale()

    cardWidth: 300

    onShownChanged: if (shown) {
        viewMonth = now.getMonth();
        viewYear = now.getFullYear();
    }

    function shift(delta: int): void {
        let m = viewMonth + delta;
        let y = viewYear;
        while (m < 0) {
            m += 12;
            y -= 1;
        }
        while (m > 11) {
            m -= 12;
            y += 1;
        }
        viewMonth = m;
        viewYear = y;
    }

    // ─── Заголовок ──────────────────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            StyledText {
                text: {
                    // именительный падеж: «Август», а не «Августа»
                    const name = root.locale.standaloneMonthName(root.viewMonth, Locale.LongFormat);
                    return name.charAt(0).toUpperCase() + name.slice(1);
                }
                color: Theme.text
                font.pixelSize: Appearance.font.size.large
                font.weight: Font.DemiBold
            }

            StyledText {
                text: root.viewYear
                color: Theme.subtext0
                font.pixelSize: Appearance.font.size.small
            }
        }

        BarButton {
            implicitWidth: 28
            implicitHeight: 28
            radius: Appearance.radius.full
            onClicked: root.shift(-1)

            MaterialIcon {
                anchors.centerIn: parent
                text: "chevron_left"
                color: Theme.subtext1
                font.pixelSize: Appearance.font.icon.normal
            }
        }

        BarButton {
            implicitWidth: 28
            implicitHeight: 28
            radius: Appearance.radius.full
            onClicked: {
                root.viewMonth = root.now.getMonth();
                root.viewYear = root.now.getFullYear();
            }

            MaterialIcon {
                anchors.centerIn: parent
                text: "today"
                color: Theme.lavender
                font.pixelSize: Appearance.font.icon.small
            }
        }

        BarButton {
            implicitWidth: 28
            implicitHeight: 28
            radius: Appearance.radius.full
            onClicked: root.shift(1)

            MaterialIcon {
                anchors.centerIn: parent
                text: "chevron_right"
                color: Theme.subtext1
                font.pixelSize: Appearance.font.icon.normal
            }
        }
    }

    // ─── Дни недели ─────────────────────────────────────────────────────────
    DayOfWeekRow {
        Layout.fillWidth: true
        locale: root.locale

        delegate: StyledText {
            required property var model

            text: model.shortName
            color: Theme.overlay1
            font.pixelSize: Appearance.font.size.tiny
            font.weight: Font.DemiBold
            font.capitalization: Font.AllUppercase
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // ─── Сетка месяца ───────────────────────────────────────────────────────
    MonthGrid {
        id: grid

        Layout.fillWidth: true
        month: root.viewMonth
        year: root.viewYear
        locale: root.locale
        spacing: 2

        delegate: Item {
            required property var model

            readonly property bool isToday: model.today
            readonly property bool inMonth: model.month === grid.month

            implicitWidth: 34
            implicitHeight: 30

            Rectangle {
                anchors.centerIn: parent
                width: 28
                height: 28
                radius: Appearance.radius.small
                color: parent.isToday ? Theme.accent : "transparent"
                opacity: parent.isToday ? 1 : 0

                Behavior on color {
                    ColorAnimation {
                        duration: Appearance.anim.normal
                    }
                }
            }

            StyledText {
                anchors.centerIn: parent
                text: model.day
                color: parent.isToday ? (Theme.isDark ? Theme.crust : Theme.base) : (parent.inMonth ? Theme.text : Theme.overlay0)
                opacity: parent.inMonth ? 1 : 0.55
                font.pixelSize: Appearance.font.size.small
                font.weight: parent.isToday ? Font.Bold : Font.Normal
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
