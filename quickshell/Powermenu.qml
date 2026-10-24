pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
  id: power
  visible: false
  property int current: 0
  property string query: ""
  property var actions: [
    { icon: "󰌾", label: "Sperren", detail: "hyprlock", command: ["hyprlock"] },
    { icon: "󰽥", label: "Standby", detail: "systemctl suspend", command: ["systemctl", "suspend"] },
    { icon: "󰍃", label: "Abmelden", detail: "Sitzung beenden", command: ["bash", "-c", "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"] },
    { icon: "󰜉", label: "Neustart", detail: "systemctl reboot", command: ["systemctl", "reboot"] },
    { icon: "󰐥", label: "Ausschalten", detail: "systemctl poweroff", command: ["systemctl", "poweroff"] }
  ]
  property var results: power.actions.filter(action => {
    const words = power.query.trim().toLocaleLowerCase().split(/\s+/).filter(Boolean);
    const haystack = [action.label, action.detail, action.command.join(" ")].join(" ").toLocaleLowerCase();
    return words.every(word => haystack.includes(word));
  })
  function toggle() {
    if (visible) { visible = false; return; }
    screen = Hyprland.focusedMonitor ? Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor.name) : Quickshell.screens[0];
    current = 0;
    search.text = "";
    query = "";
    visible = true;
    search.forceActiveFocus();
  }
  function activate(index) {
    const action = power.results[index];
    if (!action) return;
    visible = false;
    Quickshell.execDetached(action.command);
  }
  implicitWidth: 640
  implicitHeight: 250
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
  WlrLayershell.namespace: "quickshell-powermenu"
  HyprlandFocusGrab { windows: [power]; active: power.visible; onCleared: power.visible = false }
  Rectangle {
    anchors.fill: parent
    color: Theme.base
    radius: Theme.cornerRadius
    border { width: Theme.borderWidth; color: Theme.accent }
    Column {
      anchors { fill: parent; margins: 20 }
      spacing: 12
      Text {
        text: "Powermenü"
        color: Theme.accent
        font { family: "Iosevka Nerd Font"; pixelSize: Math.round(22 * Theme.fontScale); bold: true }
      }
      TextField {
        id: search
        width: parent.width
        placeholderText: "Suchen … (z. B. Neustart)"
        placeholderTextColor: Theme.mutedText
        selectionColor: Theme.accent
        selectedTextColor: Theme.base
        color: Theme.text
        font { family: "Iosevka Nerd Font"; pixelSize: Math.round(17 * Theme.fontScale) }
        background: Rectangle {
          color: Theme.surface
          radius: Theme.controlRadius
          border { width: 1; color: search.activeFocus ? Theme.accent : Theme.surfaceHover }
        }
        onTextChanged: { power.query = text; power.current = 0; }
        Keys.onEscapePressed: power.visible = false
        Keys.onDownPressed: power.current = Math.min(power.results.length - 1, power.current + 1)
        Keys.onUpPressed: power.current = Math.max(0, power.current - 1)
        onAccepted: power.activate(power.current)
      }
Row {
          id: buttons
          width: parent.width
          height: 76
          spacing: 10
        Repeater {
          model: power.results
          Rectangle {
            id: tile
            required property var modelData
            required property int index
            width: (buttons.width - buttons.spacing * (power.results.length - 1)) / Math.max(1, power.results.length)
            height: 76
            radius: Theme.controlRadius
            color: power.current === index ? Theme.surfaceHover : (mouse.containsMouse ? Theme.surfaceHover : Theme.surface)
            border { width: power.current === index ? 1 : 0; color: Theme.accent }
            Column {
              anchors.centerIn: parent
              spacing: 6
              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: tile.modelData.icon
                color: tile.index === power.current ? Theme.accent : (mouse.containsMouse ? Theme.mutedText : Theme.text)
                font { family: "Iosevka Nerd Font"; pixelSize: Math.round(24 * Theme.fontScale) }
              }
              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: tile.modelData.label
                color: tile.index === power.current ? Theme.accent : Theme.text
                font { family: "Iosevka Nerd Font"; pixelSize: Math.round(14 * Theme.fontScale) }
              }
            }
            MouseArea {
              id: mouse
              anchors.fill: parent
              hoverEnabled: true
              onClicked: {
                power.current = index;
                power.activate(index);
              }
            }
          }
        }
        Text {
          anchors.centerIn: parent
          visible: power.results.length === 0
          text: "Keine Treffer"
          color: Theme.mutedText
          font { family: "Iosevka Nerd Font"; pixelSize: Math.round(13 * Theme.fontScale) }
        }
      }
      Text {
        text: "↑ ↓ auswählen    Enter bestätigen    Esc schließen"
        color: Theme.mutedText
        font { family: "Iosevka Nerd Font"; pixelSize: Math.round(13 * Theme.fontScale) }
      }
    }
  }
}
