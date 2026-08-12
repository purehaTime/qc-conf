import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components

//
// Центр панели: загрузка CPU, памяти и видеокарты.
//
Item {
    id: root

    readonly property string popupId: "stats"

    implicitWidth: button.implicitWidth
    implicitHeight: Appearance.bar.itemHeight

    BarButton {
        id: button

        anchors.centerIn: parent
        implicitWidth: statsRow.implicitWidth + Appearance.padding.medium * 2
        implicitHeight: Appearance.bar.itemHeight
        active: Popups.isOpen(root.popupId)
        activeColor: Theme.alpha(Theme.blue, 0.14)
        onClicked: Popups.toggle(root.popupId)

        RowLayout {
            id: statsRow

            anchors.centerIn: parent
            spacing: Appearance.spacing.large

            StatMeter {
                icon: "memory"
                accent: Theme.blue
                colorByLoad: true
                value: SysInfo.cpuUsage
            }

            StatMeter {
                icon: "developer_board"
                accent: Theme.mauve
                value: SysInfo.memUsage
                valueText: `${SysInfo.memUsed.toFixed(1)}G`
            }

            StatMeter {
                visible: SysInfo.gpuAvailable
                icon: "monitor_heart"
                accent: Theme.teal
                colorByLoad: true
                value: SysInfo.gpuUsage
            }
        }
    }

    Tooltip {
        anchorItem: root
        shown: button.hovered && !Popups.isOpen(root.popupId)
        text: `CPU ${Math.round(SysInfo.cpuUsage)}%${SysInfo.cpuTempAvailable ? ` · ${Math.round(SysInfo.cpuTemp)}°C` : ""}`
        subtext: `RAM ${SysInfo.memText}` + (SysInfo.gpuAvailable ? `   ·   GPU ${Math.round(SysInfo.gpuUsage)}%` : "")
    }

    StatsPopup {
        anchorItem: root
        popupId: root.popupId
    }

    // Подробности собираем только пока открыт попап
    Connections {
        target: Popups

        function onCurrentChanged(): void {
            const open = Popups.isOpen(root.popupId);
            if (open && !root._watching) {
                root._watching = true;
                SysInfo.detailWatchers++;
            } else if (!open && root._watching) {
                root._watching = false;
                SysInfo.detailWatchers--;
            }
        }
    }

    property bool _watching: false
}
