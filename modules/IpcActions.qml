import Quickshell
import Quickshell.Io
import QtQuick
import qs.config
import qs.services

//
// Внешние команды для биндов niri:
//   qs -p ~/Code/niri-conf/quickshell_2 ipc call popup toggle volume
//   qs -p ~/Code/niri-conf/quickshell_2 ipc call audio up
//
Item {
    id: root

    IpcHandler {
        target: "popup"

        function open(id: string): void {
            Popups.open(id);
        }

        function close(): void {
            Popups.closeAll();
        }

        function toggle(id: string): void {
            Popups.toggle(id);
        }

        function list(): string {
            return "media, stats, clock, keyboard, clipboard, brightness, volume, bluetooth, network, theme";
        }
    }

    IpcHandler {
        target: "audio"

        function up(): void {
            Audio.changeVolume(Settings.volumeStep * 2);
        }

        function down(): void {
            Audio.changeVolume(-Settings.volumeStep * 2);
        }

        function mute(): void {
            Audio.toggleMute();
        }

        function micMute(): void {
            Audio.toggleInputMute();
        }

        function status(): string {
            return `${Audio.volumePercent}%${Audio.muted ? " (выкл)" : ""} · ${Audio.sinkName}`;
        }
    }

    IpcHandler {
        target: "brightness"

        function up(): void {
            Brightness.change(0, Settings.brightnessStep);
        }

        function down(): void {
            Brightness.change(0, -Settings.brightnessStep);
        }

        function set(value: int): void {
            Brightness.setValue(0, value);
        }

        function status(): string {
            return Brightness.available ? `${Brightness.percent}%` : "недоступно";
        }
    }

    IpcHandler {
        target: "media"

        function playPause(): void {
            MediaService.playPause();
        }

        function next(): void {
            MediaService.next();
        }

        function previous(): void {
            MediaService.previous();
        }

        function mute(): void {
            MediaService.toggleMute();
        }

        function status(): string {
            return MediaService.label;
        }
    }

    IpcHandler {
        target: "font"

        function up(): void {
            Appearance.changeFontScale(Appearance.fontScaleStep);
        }

        function down(): void {
            Appearance.changeFontScale(-Appearance.fontScaleStep);
        }

        function reset(): void {
            Appearance.resetFontScale();
        }

        function scale(percent: int): void {
            Appearance.setFontScale(percent / 100);
        }

        function status(): string {
            return `${Appearance.fontScalePercent}%`;
        }
    }

    IpcHandler {
        target: "theme"

        function toggle(): void {
            Theme.toggleMode();
        }

        function cycle(): void {
            Theme.cycleFlavor();
        }

        function set(flavor: string): void {
            Theme.setFlavor(flavor);
        }

        function accent(name: string): void {
            Theme.setAccent(name);
        }

        function status(): string {
            return `${Theme.flavor} · ${Theme.accentName} · шрифт ${Appearance.fontScalePercent}%`;
        }
    }
}
