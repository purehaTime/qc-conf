import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components

//
// Док-окно плеера: обложка, перемотка, выбор проигрывателя.
//
DockPopup {
    id: root

    cardWidth: 340

    readonly property MprisPlayer player: MediaService.active

    RowLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.medium

        ClippingRectangle {
            Layout.preferredWidth: Appearance.px(64)
            Layout.preferredHeight: Appearance.px(64)
            radius: Appearance.radius.normal
            color: Theme.alpha(Theme.pink, 0.16)

            Image {
                id: bigArt

                anchors.fill: parent
                source: MediaService.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: status === Image.Ready
            }

            MaterialIcon {
                anchors.centerIn: parent
                visible: !bigArt.visible
                text: "album"
                color: Theme.pink
                font.pixelSize: Appearance.font.icon.huge
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            StyledText {
                Layout.fillWidth: true
                text: MediaService.title || "Ничего не играет"
                font.pixelSize: Appearance.font.size.medium
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                visible: MediaService.artist.length > 0
                text: MediaService.artist
                color: Theme.subtext1
                font.pixelSize: Appearance.font.size.small
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                visible: MediaService.album.length > 0
                text: MediaService.album
                color: Theme.subtext0
                font.pixelSize: Appearance.font.size.tiny
                elide: Text.ElideRight
            }
        }
    }

    // ─── Перемотка ──────────────────────────────────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        visible: MediaService.canSeek
        spacing: 2

        PastelSlider {
            id: seekSlider

            Layout.fillWidth: true
            accent: Theme.pink
            barHeight: 6
            value: MediaService.length > 0 ? MediaService.position / MediaService.length : 0
            onMoved: v => MediaService.seek(v * MediaService.length)
        }

        RowLayout {
            Layout.fillWidth: true

            StyledText {
                text: MediaService.formatTime(MediaService.position)
                color: Theme.subtext0
                font.pixelSize: Appearance.font.size.tiny
                mono: true
            }

            Item {
                Layout.fillWidth: true
            }

            StyledText {
                text: MediaService.formatTime(MediaService.length)
                color: Theme.subtext0
                font.pixelSize: Appearance.font.size.tiny
                mono: true
            }
        }
    }

    // ─── Кнопки ─────────────────────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        spacing: Appearance.spacing.normal

        Item {
            Layout.fillWidth: true
        }

        BarButton {
            implicitWidth: Appearance.px(34)
            implicitHeight: Appearance.px(34)
            radius: Appearance.radius.full
            enabled: root.player?.canGoPrevious ?? false
            onClicked: MediaService.previous()

            MaterialIcon {
                anchors.centerIn: parent
                text: "skip_previous"
                fill: 1
                color: Theme.subtext1
                font.pixelSize: Appearance.font.icon.large
            }
        }

        BarButton {
            implicitWidth: Appearance.px(42)
            implicitHeight: Appearance.px(42)
            radius: Appearance.radius.full
            baseColor: Theme.alpha(Theme.pink, 0.18)
            enabled: root.player?.canTogglePlaying ?? false
            onClicked: MediaService.playPause()

            MaterialIcon {
                anchors.centerIn: parent
                text: MediaService.playing ? "pause" : "play_arrow"
                fill: 1
                color: Theme.pink
                font.pixelSize: Appearance.font.icon.huge
            }
        }

        BarButton {
            implicitWidth: Appearance.px(34)
            implicitHeight: Appearance.px(34)
            radius: Appearance.radius.full
            enabled: root.player?.canGoNext ?? false
            onClicked: MediaService.next()

            MaterialIcon {
                anchors.centerIn: parent
                text: "skip_next"
                fill: 1
                color: Theme.subtext1
                font.pixelSize: Appearance.font.icon.large
            }
        }

        Item {
            Layout.fillWidth: true
        }
    }

    // ─── Громкость плеера ───────────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        visible: MediaService.volumeSupported
        spacing: Appearance.spacing.normal

        MaterialIcon {
            text: MediaService.muted ? "volume_off" : "volume_up"
            color: Theme.subtext1
            font.pixelSize: Appearance.font.icon.small
        }

        PastelSlider {
            Layout.fillWidth: true
            accent: Theme.pink
            barHeight: 6
            value: root.player?.volume ?? 0
            onMoved: v => {
                if (root.player)
                    root.player.volume = v;
            }
        }
    }

    // ─── Список плееров ─────────────────────────────────────────────────────
    SectionLabel {
        visible: MediaService.players.length > 1
        text: "Проигрыватели"
        icon: "queue_music"
    }

    Repeater {
        model: MediaService.players.length > 1 ? MediaService.players : []

        ListRow {
            required property var modelData

            icon: modelData.playbackState === MprisPlaybackState.Playing ? "play_arrow" : "pause"
            title: modelData.identity || modelData.dbusName
            subtitle: modelData.trackTitle || ""
            active: modelData === MediaService.active
            accent: Theme.pink
            onClicked: MediaService.select(modelData)
        }
    }
}
