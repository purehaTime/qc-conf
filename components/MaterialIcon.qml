import QtQuick
import qs.config

//
// Иконка Material Symbols.
//
// Ось FILL у переменного шрифта в Qt рендерится с артефактами, поэтому
// «заливка» (fill) передаётся через насыщенность начертания: чем больше
// fill, тем толще линия. Визуально это тот же акцент, но без битых глифов.
//
Text {
    id: root

    property real fill: 0            // 0..1 — насколько «активна» иконка
    property int grade: 0
    property int baseWeight: 400

    readonly property int effectiveWeight: Math.round(Math.max(200, Math.min(700, baseWeight + fill * 220)))

    font.family: Appearance.font.icons
    font.pixelSize: Appearance.font.icon.normal
    font.weight: root.effectiveWeight
    font.variableAxes: ({
            "wght": root.effectiveWeight,
            "GRAD": root.grade
        })

    color: Theme.text
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter

    Behavior on fill {
        NumberAnimation {
            duration: Appearance.anim.normal
            easing.type: Appearance.anim.curve
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Appearance.anim.normal
        }
    }
}
