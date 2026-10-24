import QtQuick

Rectangle {
  id: root
  property alias text: label.text
  property bool selected: false
  signal clicked()
  signal scrolled(real delta)
  implicitWidth: label.implicitWidth + 22
  implicitHeight: 30
  radius: Theme.controlRadius
  color: selected ? Theme.surfaceHover : (mouse.containsMouse ? Theme.surface : Theme.crust)
  border { width: 1; color: selected ? Theme.accent : "transparent" }
  Text {
    id: label
    anchors.centerIn: parent
    color: root.selected ? Theme.accent : Theme.text
    font.family: "Iosevka Nerd Font"
    font.pixelSize: Math.round(15 * Theme.fontScale)
    textFormat: Text.PlainText
  }
  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    onClicked: root.clicked()
    onWheel: event => root.scrolled(event.angleDelta.y)
  }
}
