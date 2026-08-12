import QtQuick
import qs.config

Text {
    id: root

    property bool mono: false

    font.family: mono ? Appearance.font.mono : Appearance.font.family
    font.pixelSize: Appearance.font.size.normal
    color: Theme.text
    verticalAlignment: Text.AlignVCenter
    renderType: Text.QtRendering

    Behavior on color {
        ColorAnimation {
            duration: Appearance.anim.normal
        }
    }
}
