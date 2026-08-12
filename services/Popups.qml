pragma Singleton

//
// Один открытый попап на всю оболочку: открытие нового закрывает предыдущий.
//

import Quickshell
import QtQuick

Singleton {
    id: root

    property string current: ""

    function isOpen(id: string): bool {
        return current === id && id !== "";
    }

    function open(id: string): void {
        current = id;
    }

    function close(id: string): void {
        if (current === id)
            current = "";
    }

    function toggle(id: string): void {
        current = current === id ? "" : id;
    }

    function closeAll(): void {
        current = "";
    }
}
