import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.modules.bar.media
import qs.modules.bar.stats
import qs.modules.bar.clock
import qs.modules.bar.tray

//
// Верхняя панель: слева плеер, по центру метрики, справа системный блок и часы.
//
PanelWindow {
    id: root

    required property ShellScreen modelData

    screen: modelData
    color: "transparent"
    implicitHeight: Appearance.bar.height
    exclusiveZone: Appearance.bar.height

    anchors {
        top: true
        left: true
        right: true
    }

    WlrLayershell.namespace: "quickshell:bar"
    WlrLayershell.layer: WlrLayer.Top

    Rectangle {
        id: background

        anchors.fill: parent
        color: Theme.barBg

        Behavior on color {
            ColorAnimation {
                duration: Appearance.anim.slow
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: Theme.separator
        }
    }

    // ─── Слева: плеер ───────────────────────────────────────────────────────
    MediaControls {
        anchors.left: parent.left
        anchors.leftMargin: Appearance.bar.sideMargin
        anchors.verticalCenter: parent.verticalCenter
    }

    // ─── По центру: CPU / RAM / GPU ─────────────────────────────────────────
    SystemStats {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    // ─── Справа: системный блок и часы ──────────────────────────────────────
    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: Appearance.bar.sideMargin
        anchors.verticalCenter: parent.verticalCenter
        spacing: Appearance.spacing.small

        TrayCluster {}

        ClockWidget {}
    }
}
