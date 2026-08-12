import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components

//
// Левая часть панели: обложка, название трека и кнопки управления.
//
RowLayout {
    id: root

    // Ширина названия трека задаётся в config/Settings.qml → mediaTextMaxWidth
    property int maxTextWidth: Settings.mediaTextMaxWidth
    readonly property bool has: MediaService.hasPlayer
    readonly property string popupId: "media"

    spacing: Appearance.spacing.tiny

    // ─── Информация о треке ─────────────────────────────────────────────────
    Item {
        id: info

        Layout.preferredWidth: infoButton.implicitWidth
        Layout.preferredHeight: Appearance.bar.itemHeight

        BarButton {
            id: infoButton

            anchors.fill: parent
            implicitWidth: infoRow.implicitWidth + Appearance.padding.normal * 2
            active: Popups.isOpen(root.popupId)
            activeColor: Theme.alpha(Theme.pink, 0.16)
            onClicked: Popups.toggle(root.popupId)
            onRightClicked: MediaService.playPause()
            onWheelUp: MediaService.next()
            onWheelDown: MediaService.previous()

            RowLayout {
                id: infoRow

                anchors.left: parent.left
                anchors.leftMargin: Appearance.padding.small
                anchors.right: parent.right
                anchors.rightMargin: Appearance.padding.small
                anchors.verticalCenter: parent.verticalCenter
                spacing: Appearance.spacing.normal

                ClippingRectangle {
                    Layout.preferredWidth: Appearance.px(22)
                    Layout.preferredHeight: Appearance.px(22)
                    radius: Appearance.radius.small
                    color: Theme.alpha(Theme.pink, 0.18)

                    Image {
                        id: art

                        anchors.fill: parent
                        source: MediaService.artUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        visible: status === Image.Ready
                    }

                    MaterialIcon {
                        anchors.centerIn: parent
                        visible: !art.visible
                        text: root.has ? "music_note" : "music_off"
                        color: Theme.pink
                        font.pixelSize: Appearance.font.icon.small
                        fill: MediaService.playing ? 1 : 0
                    }
                }

                MarqueeText {
                    Layout.alignment: Qt.AlignVCenter
                    text: MediaService.label
                    color: root.has ? Theme.text : Theme.overlay1
                    pixelSize: Appearance.font.size.normal
                    weight: MediaService.playing ? Font.DemiBold : Font.Normal
                    maxWidth: root.maxTextWidth
                }
            }
        }

        Tooltip {
            id: infoTooltip

            anchorItem: info
            text: MediaService.title || MediaService.label
            subtext: MediaService.artist || MediaService.identity
            shown: infoButton.hovered && !Popups.isOpen(root.popupId) && root.has
        }

        MediaPopup {
            anchorItem: info
            popupId: root.popupId
            alignment: Qt.AlignLeft
        }
    }

    // ─── Кнопки ─────────────────────────────────────────────────────────────
    BarButton {
        implicitWidth: Appearance.px(28)
        enabled: root.has
        onClicked: MediaService.previous()

        MaterialIcon {
            anchors.centerIn: parent
            text: "skip_previous"
            color: Theme.subtext1
            fill: 1
            font.pixelSize: Appearance.font.icon.normal
        }
    }

    BarButton {
        implicitWidth: Appearance.px(30)
        enabled: root.has
        activeColor: Theme.alpha(Theme.green, 0.18)
        active: MediaService.playing
        onClicked: MediaService.playPause()

        MaterialIcon {
            anchors.centerIn: parent
            text: MediaService.playing ? "pause" : "play_arrow"
            color: MediaService.playing ? Theme.green : Theme.subtext1
            fill: 1
            font.pixelSize: Appearance.font.icon.large
        }
    }

    BarButton {
        implicitWidth: Appearance.px(28)
        enabled: root.has
        onClicked: MediaService.next()

        MaterialIcon {
            anchors.centerIn: parent
            text: "skip_next"
            color: Theme.subtext1
            fill: 1
            font.pixelSize: Appearance.font.icon.normal
        }
    }

    BarButton {
        implicitWidth: Appearance.px(28)
        onClicked: MediaService.toggleMute()

        MaterialIcon {
            anchors.centerIn: parent
            text: MediaService.muted ? "volume_off" : "volume_up"
            color: MediaService.muted ? Theme.red : Theme.subtext1
            fill: MediaService.muted ? 1 : 0
            font.pixelSize: Appearance.font.icon.normal
        }
    }
}
