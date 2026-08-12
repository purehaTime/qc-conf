pragma Singleton

//
// Сеть через NetworkManager (нативный модуль Quickshell.Networking).
//

import Quickshell
import Quickshell.Networking
import QtQuick
import qs.config

Singleton {
    id: root

    readonly property var devices: Networking.devices.values
    readonly property NetworkDevice wifiDevice: devices.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property NetworkDevice wiredDevice: devices.find(d => d.type === DeviceType.Wired) ?? null

    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiHardwareEnabled: Networking.wifiHardwareEnabled
    readonly property bool wiredConnected: wiredDevice?.connected ?? false
    readonly property bool wifiConnected: wifiDevice?.connected ?? false
    readonly property bool online: Networking.connectivity === NetworkConnectivity.Full || wiredConnected || wifiConnected

    // Активная wifi-сеть
    readonly property var activeWifi: {
        if (!wifiDevice)
            return null;
        return wifiDevice.networks.values.find(n => n.connected) ?? null;
    }

    // Видимые сети: убираем дубли по имени, сортируем по сигналу
    readonly property var wifiNetworks: {
        if (!wifiDevice)
            return [];
        const seen = ({});
        const list = [];
        for (const n of wifiDevice.networks.values) {
            if (!n.name)
                continue;
            const prev = seen[n.name];
            if (prev !== undefined) {
                if ((n.signalStrength ?? 0) > (list[prev].signalStrength ?? 0))
                    list[prev] = n;
                continue;
            }
            seen[n.name] = list.length;
            list.push(n);
        }
        return list.sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            return (b.signalStrength ?? 0) - (a.signalStrength ?? 0);
        });
    }

    readonly property string wiredSpeed: {
        const s = wiredDevice?.linkSpeed ?? 0;
        if (s <= 0)
            return "";
        return s >= 1000 ? `${(s / 1000).toFixed(0)} Гбит/с` : `${s} Мбит/с`;
    }

    readonly property string statusText: {
        if (wiredConnected)
            return `Ethernet${wiredSpeed ? ` · ${wiredSpeed}` : ""}`;
        if (activeWifi)
            return `${activeWifi.name} · ${Math.round(activeWifi.signalStrength ?? 0)}%`;
        if (!wifiEnabled && !wiredDevice)
            return "Wi-Fi выключен";
        if (!wifiEnabled)
            return "Wi-Fi выключен";
        return "Нет подключения";
    }

    readonly property string icon: {
        if (wiredConnected)
            return "lan";
        if (!wifiEnabled)
            return "wifi_off";
        if (!activeWifi)
            return "signal_wifi_bad";
        return signalIcon(activeWifi.signalStrength ?? 0);
    }

    function signalIcon(strength: real): string {
        if (strength >= 75)
            return "signal_wifi_4_bar";
        if (strength >= 50)
            return "network_wifi_3_bar";
        if (strength >= 25)
            return "network_wifi_2_bar";
        if (strength > 0)
            return "network_wifi_1_bar";
        return "signal_wifi_0_bar";
    }

    function toggleWifi(): void {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    function rescan(): void {
        if (wifiDevice)
            wifiDevice.scannerEnabled = true;
    }

    function isSecured(network): bool {
        return network && network.security !== undefined && network.security !== WifiSecurityType.Open;
    }

    function connectTo(network): void {
        if (network)
            network.connect();
    }

    function disconnect(network): void {
        if (network)
            network.disconnect();
    }

    function forget(network): void {
        if (network)
            network.forget();
    }

    function openSettings(): void {
        Quickshell.execDetached(["sh", "-c", Settings.networkSettings]);
    }
}
