import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components

//
// История буфера обмена (cliphist).
//
TrayItem {
    id: root

    popupId: "clipboard"
    icon: "content_paste"
    iconColor: Theme.peach
    popupWidth: 360
    tooltipText: "Буфер обмена"
    tooltipSubtext: ClipboardService.entries.length > 0 ? `${ClipboardService.entries.length} записей` : "cliphist"

    onPopupOpenChanged: {
        if (popupOpen) {
            ClipboardService.watchers++;
            ClipboardService.refresh();
        } else {
            ClipboardService.watchers = Math.max(0, ClipboardService.watchers - 1);
            ClipboardService.query = "";
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small

        SectionLabel {
            text: "Буфер обмена"
            icon: "content_paste"
            accent: Theme.peach
        }

        BarButton {
            implicitWidth: 26
            implicitHeight: 26
            radius: Appearance.radius.full
            onClicked: ClipboardService.wipe()

            MaterialIcon {
                anchors.centerIn: parent
                text: "delete_sweep"
                color: Theme.red
                font.pixelSize: Appearance.font.icon.small
            }
        }
    }

    ScrollColumn {
        maxHeight: 320

        Repeater {
            model: ClipboardService.filtered

            ListRow {
                id: entryRow

                required property var modelData

                title: modelData.isImage ? "Изображение" : modelData.preview
                subtitle: modelData.isImage ? modelData.preview : ""
                icon: modelData.isImage ? "image" : "content_copy"
                accent: Theme.peach
                onClicked: {
                    ClipboardService.copy(modelData);
                    Popups.close(root.popupId);
                }

                BarButton {
                    implicitWidth: 24
                    implicitHeight: 24
                    radius: Appearance.radius.full
                    visible: entryRow.hovered
                    onClicked: ClipboardService.remove(entryRow.modelData)

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: "close"
                        color: Theme.red
                        font.pixelSize: Appearance.font.icon.small
                    }
                }
            }
        }
    }

    StyledText {
        Layout.fillWidth: true
        visible: ClipboardService.entries.length === 0
        text: ClipboardService.loading ? "Загрузка…" : "История пуста"
        color: Theme.overlay1
        font.pixelSize: Appearance.font.size.small
        horizontalAlignment: Text.AlignHCenter
    }
}
