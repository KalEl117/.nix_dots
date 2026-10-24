pragma Singleton
import QtQuick

QtObject {
  readonly property color base: "#1e1e2e"
  readonly property color translucentBase: "#dd1e1e2e"
  readonly property color crust: "#11111b"
  readonly property color surface: "#313244"
  readonly property color surfaceHover: "#45475a"
  readonly property color text: "#cdd6f4"
  readonly property color mutedText: "#a6adc8"
  readonly property color accent: "#cba6f7"
  readonly property color critical: "#f38ba8"

  readonly property int borderWidth: 2
  readonly property int cornerRadius: 16
  readonly property int controlRadius: 10

  property real fontScale: 1.0
}
