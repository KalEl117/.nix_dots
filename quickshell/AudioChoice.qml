pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

ComboBox {
  id: control
  property string selected: ""
  textRole: "label"
  valueRole: "name"
  currentIndex: {
    for (let i = 0; i < count; ++i) {
      if (String(valueAt(i)) === selected) return i;
    }
    return -1;
  }
  implicitHeight: 36
  font { family: "Iosevka Nerd Font"; pixelSize: Math.round(13 * Theme.fontScale) }
  contentItem: Text {
    leftPadding: 10
    rightPadding: 28
    text: control.displayText
    font: control.font
    color: Theme.text
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    textFormat: Text.PlainText
  }
  background: Rectangle {
    color: Theme.surface
    radius: Theme.controlRadius
    border { width: 1; color: control.activeFocus ? Theme.accent : Theme.surfaceHover }
  }
  delegate: ItemDelegate {
    id: option
    required property var modelData
    required property int index
    width: control.width
    highlighted: control.highlightedIndex === index
    contentItem: Text {
      text: option.modelData.label
      font: control.font
      color: Theme.text
      wrapMode: Text.WordWrap
      textFormat: Text.PlainText
    }
    background: Rectangle { color: option.highlighted ? Theme.surfaceHover : Theme.base }
  }
  popup: Popup {
    y: control.height + 4
    width: control.width
    padding: 4
    implicitHeight: Math.min(contentItem.implicitHeight + 8, 260)
    contentItem: ListView {
      clip: true
      implicitHeight: contentHeight
      model: control.popup.visible ? control.delegateModel : null
      currentIndex: control.highlightedIndex
      ScrollIndicator.vertical: ScrollIndicator {}
    }
    background: Rectangle { color: Theme.base; radius: Theme.controlRadius; border { width: 1; color: Theme.accent } }
  }
}
