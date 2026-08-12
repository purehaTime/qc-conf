import Quickshell
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components

//
// Сеть: Wi-Fi и проводное подключение.
//
TrayItem {
    id: root

    popupId: "network"
    icon: NetworkService.icon
    iconColor: NetworkService.online ? Theme.green : Theme.overlay1
    iconFill: NetworkService.online ? 1 : 0
    popupWidth: 340
    tooltipText: NetworkService.wiredConnected ? "Проводная сеть" : "Wi-Fi"
    tooltipSubtext: NetworkService.statusText

    onMiddleClicked: NetworkService.toggleWifi()
    onRightClicked: NetworkService.openSettings()
    onClicked: if (!popupOpen)
        NetworkService.rescan()

    // ─── Проводное ──────────────────────────────────────────────────────────
    SectionLabel {
        visible: NetworkService.wiredDevice !== null
        text: "Проводная сеть"
        icon: "lan"
        accent: Theme.teal
    }

    ListRow {
        visible: NetworkService.wiredDevice !== null
        title: NetworkService.wiredDevice?.name ?? ""
        subtitle: NetworkService.wiredConnected ? (NetworkService.wiredSpeed || "подключено") : "не подключено"
        icon: NetworkService.wiredConnected ? "lan" : "cable"
        accent: Theme.teal
        active: NetworkService.wiredConnected
    }

    // ─── Wi-Fi ──────────────────────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        visible: NetworkService.wifiDevice !== null
        spacing: Appearance.spacing.normal

        SectionLabel {
            text: "Wi-Fi"
            icon: "wifi"
            accent: Theme.green
        }

        BarButton {
            implicitWidth: 26
            implicitHeight: 26
            radius: Appearance.radius.full
            visible: NetworkService.wifiEnabled
            onClicked: NetworkService.rescan()

            MaterialIcon {
                anchors.centerIn: parent
                text: "refresh"
                color: Theme.subtext1
                font.pixelSize: Appearance.font.icon.small
            }
        }

        ToggleSwitch {
            checked: NetworkService.wifiEnabled
            accent: Theme.green
            onToggled: NetworkService.toggleWifi()
        }
    }

    ScrollColumn {
        maxHeight: 300
        visible: NetworkService.wifiDevice !== null && NetworkService.wifiEnabled

        Repeater {
            model: NetworkService.wifiNetworks

            ListRow {
                required property var modelData

                title: modelData.name
                subtitle: {
                    const parts = [];
                    if (modelData.connected)
                        parts.push("Подключено");
                    else if (modelData.known)
                        parts.push("Известная сеть");
                    if (NetworkService.isSecured(modelData))
                        parts.push("защищена");
                    parts.push(`${Math.round(modelData.signalStrength ?? 0)}%`);
                    return parts.join(" · ");
                }
                icon: NetworkService.signalIcon(modelData.signalStrength ?? 0)
                accent: Theme.green
                active: modelData.connected
                busy: modelData.stateChanging
                onClicked: {
                    if (modelData.connected)
                        NetworkService.disconnect(modelData);
                    else
                        NetworkService.connectTo(modelData);
                }
                onRightClicked: if (modelData.known)
                    NetworkService.forget(modelData)

                MaterialIcon {
                    visible: NetworkService.isSecured(modelData)
                    text: "lock"
                    color: Theme.overlay1
                    font.pixelSize: Appearance.font.icon.small
                }
            }
        }
    }

    StyledText {
        Layout.fillWidth: true
        visible: NetworkService.wifiEnabled && NetworkService.wifiNetworks.length === 0
        text: "Сети не найдены"
        color: Theme.overlay1
        font.pixelSize: Appearance.font.size.small
        horizontalAlignment: Text.AlignHCenter
    }

    BarButton {
        Layout.fillWidth: true
        implicitHeight: 30
        radius: Appearance.radius.normal
        baseColor: Theme.alpha(Theme.surface0, 0.5)
        onClicked: NetworkService.openSettings()

        RowLayout {
            anchors.centerIn: parent
            spacing: Appearance.spacing.small

            MaterialIcon {
                text: "settings"
                color: Theme.subtext1
                font.pixelSize: Appearance.font.icon.small
            }

            StyledText {
                text: "Настройки сети"
                color: Theme.subtext1
                font.pixelSize: Appearance.font.size.small
            }
        }
    }
}
