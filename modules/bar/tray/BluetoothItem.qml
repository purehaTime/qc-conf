import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.components

//
// Bluetooth: питание адаптера, поиск и подключение устройств.
//
TrayItem {
    id: root

    popupId: "bluetooth"
    icon: BluetoothService.icon
    iconColor: BluetoothService.enabled ? Theme.blue : Theme.overlay1
    iconFill: BluetoothService.connected.length > 0 ? 1 : 0
    indicator: BluetoothService.connected.length > 0
    indicatorColor: Theme.blue
    popupWidth: 330
    tooltipText: "Bluetooth"
    tooltipSubtext: BluetoothService.statusText

    onMiddleClicked: BluetoothService.toggle()
    onRightClicked: BluetoothService.openSettings()

    RowLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.normal

        SectionLabel {
            text: "Bluetooth"
            icon: "bluetooth"
            accent: Theme.blue
        }

        ToggleSwitch {
            checked: BluetoothService.enabled
            accent: Theme.blue
            onToggled: BluetoothService.toggle()
        }
    }

    StyledText {
        Layout.fillWidth: true
        text: BluetoothService.statusText
        color: Theme.subtext0
        font.pixelSize: Appearance.font.size.small
        elide: Text.ElideRight
    }

    // ─── Подключённые и сопряжённые ─────────────────────────────────────────
    ScrollColumn {
        maxHeight: 240
        visible: BluetoothService.enabled

        Repeater {
            model: [...BluetoothService.connected, ...BluetoothService.paired]

            ListRow {
                required property var modelData

                title: BluetoothService.deviceName(modelData)
                subtitle: {
                    if (modelData.pairing)
                        return "Сопряжение…";
                    if (modelData.connected)
                        return modelData.batteryAvailable ? `Подключено · ${Math.round(modelData.battery * 100)}%` : "Подключено";
                    return "Сопряжено";
                }
                icon: BluetoothService.deviceIcon(modelData)
                accent: Theme.blue
                active: modelData.connected
                busy: modelData.pairing || modelData.state === BluetoothDeviceState.Connecting
                onClicked: BluetoothService.toggleDevice(modelData)
                onRightClicked: modelData.forget()
            }
        }
    }

    // ─── Поиск ──────────────────────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        visible: BluetoothService.enabled
        spacing: Appearance.spacing.normal

        SectionLabel {
            text: BluetoothService.discovering ? "Поиск…" : "Рядом"
            icon: "bluetooth_searching"
            accent: Theme.subtext0
        }

        ToggleSwitch {
            checked: BluetoothService.discovering
            accent: Theme.blue
            onToggled: BluetoothService.toggleDiscovery()
        }
    }

    ScrollColumn {
        maxHeight: 160
        visible: BluetoothService.enabled && BluetoothService.discovering

        Repeater {
            model: BluetoothService.nearby

            ListRow {
                required property var modelData

                title: BluetoothService.deviceName(modelData)
                subtitle: modelData.address
                icon: BluetoothService.deviceIcon(modelData)
                accent: Theme.blue
                busy: modelData.pairing
                onClicked: BluetoothService.toggleDevice(modelData)
            }
        }
    }

    BarButton {
        Layout.fillWidth: true
        implicitHeight: 30
        radius: Appearance.radius.normal
        baseColor: Theme.alpha(Theme.surface0, 0.5)
        onClicked: BluetoothService.openSettings()

        RowLayout {
            anchors.centerIn: parent
            spacing: Appearance.spacing.small

            MaterialIcon {
                text: "settings"
                color: Theme.subtext1
                font.pixelSize: Appearance.font.icon.small
            }

            StyledText {
                text: "Настройки Bluetooth"
                color: Theme.subtext1
                font.pixelSize: Appearance.font.size.small
            }
        }
    }
}
