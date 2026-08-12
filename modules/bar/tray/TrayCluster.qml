import QtQuick
import QtQuick.Layouts
import qs.config

//
// Системный блок справа — слегка затемнённый контейнер.
//
Rectangle {
    id: root

    implicitWidth: row.implicitWidth + Appearance.padding.small * 2
    implicitHeight: Appearance.bar.itemHeight + 4
    radius: Appearance.radius.large
    color: Theme.trayBg

    Behavior on color {
        ColorAnimation {
            duration: Appearance.anim.slow
        }
    }

    RowLayout {
        id: row

        anchors.centerIn: parent
        spacing: 0

        KeyboardItem {}

        ClipboardItem {}

        BrightnessItem {}

        VolumeItem {}

        BluetoothItem {}

        NetworkItem {}

        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 16
            Layout.leftMargin: Appearance.spacing.small
            Layout.rightMargin: Appearance.spacing.small
            color: Theme.separator
        }

        ThemeItem {}
    }
}
