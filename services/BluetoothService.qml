pragma Singleton

//
// Bluetooth через BlueZ (нативный модуль Quickshell.Bluetooth).
//

import Quickshell
import Quickshell.Bluetooth
import QtQuick
import qs.config

Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property bool discovering: adapter?.discovering ?? false

    readonly property var allDevices: adapter ? adapter.devices.values : []
    readonly property var connected: allDevices.filter(d => d.connected)
    readonly property var paired: allDevices.filter(d => (d.paired || d.bonded) && !d.connected)
    readonly property var nearby: allDevices.filter(d => !d.paired && !d.bonded && !d.connected && d.name)

    readonly property string statusText: {
        if (!available)
            return "Адаптер не найден";
        if (!enabled)
            return "Выключен";
        if (connected.length === 0)
            return "Нет подключённых";
        if (connected.length === 1)
            return connected[0].name || connected[0].deviceName || connected[0].address;
        return `Подключено: ${connected.length}`;
    }

    readonly property string icon: {
        if (!available || !enabled)
            return "bluetooth_disabled";
        if (connected.length > 0)
            return "bluetooth_connected";
        if (discovering)
            return "bluetooth_searching";
        return "bluetooth";
    }

    // bluez icon name → Material Symbols
    function deviceIcon(device): string {
        const i = device?.icon ?? "";
        if (i.includes("headset") || i.includes("headphone"))
            return "headphones";
        if (i.includes("audio"))
            return "speaker";
        if (i.includes("mouse"))
            return "mouse";
        if (i.includes("keyboard"))
            return "keyboard";
        if (i.includes("phone"))
            return "smartphone";
        if (i.includes("computer"))
            return "computer";
        if (i.includes("watch"))
            return "watch";
        if (i.includes("gaming") || i.includes("joystick"))
            return "sports_esports";
        if (i.includes("printer"))
            return "print";
        return "bluetooth";
    }

    function deviceName(device): string {
        return device?.name || device?.deviceName || device?.address || "Устройство";
    }

    function toggle(): void {
        if (adapter)
            adapter.enabled = !adapter.enabled;
    }

    function toggleDiscovery(): void {
        if (adapter)
            adapter.discovering = !adapter.discovering;
    }

    function toggleDevice(device): void {
        if (!device)
            return;
        if (device.connected)
            device.disconnect();
        else if (device.paired || device.bonded)
            device.connect();
        else
            device.pair();
    }

    function openSettings(): void {
        Quickshell.execDetached(["sh", "-c", Settings.bluetoothSettings]);
    }
}
