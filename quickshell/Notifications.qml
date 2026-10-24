pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Notifications

Scope {
  id: root
  function appIconSource(icon) {
    if (!icon) return "";
    if (icon.startsWith("/") || icon.startsWith("file:")) return icon;
    return Quickshell.iconPath(icon);
  }
  NotificationServer {
    id: server
    actionsSupported: true
    bodySupported: true
    imageSupported: true
    onNotification: notification => { notification.tracked = true; }
  }
  PanelWindow {
    id: popups
    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    visible: server.trackedNotifications.values.length > 0
    anchors { top: true; right: true }
    margins { top: 52; right: 12 }
    implicitWidth: 380
    implicitHeight: Math.min(stack.implicitHeight, (screen?.height ?? 800) - 80)
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"
    Flickable {
      anchors.fill: parent
      contentHeight: stack.implicitHeight
      clip: true
      Column {
        id: stack
        width: parent.width
        spacing: 10
        Repeater {
          model: server.trackedNotifications
          Rectangle {
            id: card
            required property var modelData
            width: stack.width
            height: content.implicitHeight + 30
            color: Theme.base
            radius: Theme.cornerRadius
            border {
              width: Theme.borderWidth
              color: card.modelData.urgency === NotificationUrgency.Critical ? Theme.critical : Theme.accent
            }
            Timer {
              interval: card.modelData.expireTimeout > 0 ? card.modelData.expireTimeout : 5000
              running: card.modelData.expireTimeout !== 0 && card.modelData.urgency !== NotificationUrgency.Critical && !hover.containsMouse
              onTriggered: card.modelData.expire()
            }
            MouseArea {
              id: hover
              anchors.fill: parent
              hoverEnabled: true
              acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
              onClicked: event => {
                if (event.button === Qt.RightButton) {
                  const all = server.trackedNotifications.values.slice();
                  all.forEach(n => n.dismiss());
                } else if (event.button === Qt.MiddleButton) {
                  const action = card.modelData.actions.find(a => a.identifier === "default");
                  if (action) action.invoke();
                } else card.modelData.dismiss();
              }
            }
            Column {
              id: content
              anchors { left: parent.left; right: parent.right; top: parent.top; margins: 15 }
              spacing: 8
              Row {
                width: parent.width
                height: 24
                spacing: 10
                Image {
                  id: appIcon
                  source: root.appIconSource(card.modelData.appIcon)
                  visible: source !== ""
                  width: visible ? 24 : 0
                  height: visible ? 24 : 0
                  sourceSize: Qt.size(24, 24)
                  fillMode: Image.PreserveAspectFit
                }
                Text {
                  text: card.modelData.appName
                  color: Theme.mutedText
                  width: parent.width - appIcon.width - parent.spacing
                  height: parent.height
                  verticalAlignment: Text.AlignVCenter
                  elide: Text.ElideRight
                  textFormat: Text.PlainText
                  font.family: "Iosevka Nerd Font"
                }
              }
              Text { text: card.modelData.summary; color: Theme.text; font.family: "Iosevka Nerd Font"; font.pixelSize: Math.round(17 * Theme.fontScale); font.bold: true; width: parent.width; wrapMode: Text.Wrap; textFormat: Text.PlainText }
              Text { text: card.modelData.body; visible: text !== ""; color: Theme.text; width: parent.width; wrapMode: Text.Wrap; textFormat: Text.PlainText; font.family: "Iosevka Nerd Font" }
              Image { source: card.modelData.image; visible: source.toString() !== ""; width: parent.width; height: visible ? 120 : 0; fillMode: Image.PreserveAspectFit }
              Flow {
                width: parent.width
                spacing: 6
                Repeater {
                  model: card.modelData.actions
                  Chip { required property var modelData; text: modelData.text; onClicked: modelData.invoke() }
                }
              }
            }
          }
        }
      }
    }
  }
}
