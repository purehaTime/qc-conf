//
// Точка входа. Запуск:  qs -p ~/Code/niri-conf/quickshell_2
//

import Quickshell
import QtQuick
import qs.config
import qs.modules
import qs.modules.bar

ShellRoot {
    id: root

    // Команды для биндов niri (qs ipc call …)
    IpcActions {}

    Variants {
        model: Quickshell.screens.filter(s => Settings.barScreens.length === 0 || Settings.barScreens.includes(s.name))

        Bar {}
    }
}
