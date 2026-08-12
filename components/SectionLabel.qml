import QtQuick
import QtQuick.Layouts
import qs.config

RowLayout {
    id: root

    property string text: ""
    property string icon: ""
    property color accent: Theme.subtext0

    Layout.fillWidth: true
    spacing: Appearance.spacing.small

    MaterialIcon {
        visible: root.icon.length > 0
        text: root.icon
        color: root.accent
        font.pixelSize: Appearance.font.icon.small
    }

    StyledText {
        text: root.text
        color: root.accent
        font.pixelSize: Appearance.font.size.tiny
        font.weight: Font.DemiBold
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 0.8
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        height: 1
        color: Theme.separator
    }
}
