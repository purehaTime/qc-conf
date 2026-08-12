import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components

//
// Раскладка клавиатуры.
//
TrayItem {
    id: root

    popupId: "keyboard"
    icon: "keyboard"
    label: KeyboardLayout.currentShort
    iconColor: Theme.mauve
    popupWidth: 240
    tooltipText: KeyboardLayout.currentName
    tooltipSubtext: KeyboardLayout.layouts.length > 1 ? "Колесо — переключить" : "Одна раскладка"

    onWheelUp: KeyboardLayout.next()
    onWheelDown: KeyboardLayout.prev()
    onMiddleClicked: KeyboardLayout.next()

    SectionLabel {
        text: "Раскладки"
        icon: "language"
        accent: Theme.mauve
    }

    Repeater {
        model: KeyboardLayout.layouts

        ListRow {
            required property int index
            required property var modelData

            title: modelData
            subtitle: KeyboardLayout.shortName(modelData)
            icon: "keyboard_alt"
            accent: Theme.mauve
            active: index === KeyboardLayout.currentIndex
            onClicked: {
                KeyboardLayout.switchTo(index);
                Popups.close(root.popupId);
            }
        }
    }

    StyledText {
        Layout.fillWidth: true
        visible: KeyboardLayout.layouts.length === 0
        text: "niri не отвечает"
        color: Theme.overlay1
        font.pixelSize: Appearance.font.size.small
    }
}
