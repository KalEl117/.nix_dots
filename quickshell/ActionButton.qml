import QtQuick

Rectangle {
  id: root
  property alias text: label.text
  property bool active: false
  property bool compact: false
  signal clicked()

  implicitWidth: compact ? 38 : label.implicitWidth + 24
  implicitHeight: 34
  radius: Theme.controlRadius
  color: active ? Theme.surfaceHover : (mouse.containsMouse ? Theme.surfaceHover : Theme.surface)
  border { width: 1; color: active ? Theme.accent : Theme.surfaceHover }

  Text {
    id: label
    anchors.centerIn: parent
    color: root.active ? Theme.accent : Theme.text
    font.family: "Iosevka Nerd Font"
    font.pixelSize: Math.round(14 * Theme.fontScale)
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    onClicked: root.clicked()
  }
}
