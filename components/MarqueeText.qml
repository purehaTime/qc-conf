import QtQuick
import QtQuick.Effects
import qs.config

//
// Текст, который превращается в бегущую строку, если не помещается в maxWidth.
// Пока влезает — ведёт себя как обычный Text.
//
Item {
    id: root

    property string text: ""
    property color color: Theme.text
    property int pixelSize: Appearance.font.size.normal
    property int weight: Font.Normal
    property string family: Appearance.font.family

    property int maxWidth: 400
    property real speed: Settings.marqueeSpeed      // px/сек
    property int pause: Settings.marqueePause       // пауза в начале цикла, мс
    property int gap: Settings.marqueeGap           // разрыв между повторами
    property bool active: true                      // выключить прокрутку
    property bool fade: true                        // мягкие края при прокрутке

    readonly property real textWidth: primary.implicitWidth
    readonly property bool overflowing: textWidth > maxWidth + 0.5
    readonly property bool scrolling: overflowing && active

    implicitWidth: Math.min(maxWidth, textWidth)
    implicitHeight: primary.implicitHeight

    onTextChanged: {
        content.x = 0;
        if (scroll.running)
            scroll.restart();
    }

    Item {
        id: viewport

        anchors.fill: parent
        clip: true

        layer.enabled: root.scrolling && root.fade
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: fadeMask
            maskThresholdMin: 0
            maskSpreadAtMin: 0
        }

        Row {
            id: content

            spacing: root.gap
            height: parent.height

            Text {
                id: primary

                text: root.text
                color: root.color
                font.family: root.family
                font.pixelSize: root.pixelSize
                font.weight: root.weight
                verticalAlignment: Text.AlignVCenter
                height: content.height
                renderType: Text.QtRendering
            }

            Text {
                visible: root.scrolling
                text: root.text
                color: root.color
                font.family: root.family
                font.pixelSize: root.pixelSize
                font.weight: root.weight
                verticalAlignment: Text.AlignVCenter
                height: content.height
                renderType: Text.QtRendering
            }
        }
    }

    // Маска для мягких краёв: белое — видно, прозрачное — спрятано
    Item {
        id: fadeMask

        anchors.fill: parent
        visible: false
        layer.enabled: true

        Rectangle {
            anchors.fill: parent

            gradient: Gradient {
                orientation: Gradient.Horizontal

                GradientStop {
                    position: 0
                    color: "transparent"
                }

                GradientStop {
                    position: Math.min(0.15, 12 / Math.max(1, root.width))
                    color: "white"
                }

                GradientStop {
                    position: 1 - Math.min(0.15, 12 / Math.max(1, root.width))
                    color: "white"
                }

                GradientStop {
                    position: 1
                    color: "transparent"
                }
            }
        }
    }

    SequentialAnimation {
        id: scroll

        running: root.scrolling && root.visible
        loops: Animation.Infinite

        onRunningChanged: if (!running)
            content.x = 0

        PauseAnimation {
            duration: root.pause
        }

        NumberAnimation {
            target: content
            property: "x"
            from: 0
            to: -(primary.implicitWidth + root.gap)
            duration: Math.max(1, (primary.implicitWidth + root.gap) / Math.max(1, root.speed) * 1000)
            easing.type: Easing.Linear
        }
    }
}
