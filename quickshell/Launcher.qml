pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import "Keybinds.js" as Keybinds

PanelWindow {
  id: menu
  visible: false
  property string mode: "apps"
  property var rows: []
  property string loadError: ""
  property var results: {
    const query = search.text.toLocaleLowerCase();
    const source = mode === "apps"
      ? DesktopEntries.applications.values.map(app => ({label: app.name, detail: app.comment || "", app: app}))
        .sort((a, b) => a.label.localeCompare(b.label))
      : rows;
    return source.filter(row => Keybinds.matches(row, query));
  }
  function toggle(nextMode) {
    if (!["apps", "clipboard", "keybinds"].includes(nextMode)) return;
    if (visible && mode === nextMode) { visible = false; return; }
    mode = nextMode;
    rows = [];
    loadError = "";
    search.text = "";
    screen = Hyprland.focusedMonitor ? Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor.name) : Quickshell.screens[0];
    visible = true;
    if (mode === "clipboard") clipboard.running = true;
    if (mode === "keybinds") bindings.running = true;
    search.forceActiveFocus();
  }
  function choose(index) {
    const row = results[index];
    if (!row || !visible) return;
    if (mode === "keybinds") {
      if (!row.invocation || row.invocation.length === 0) return;
      visible = false;
      shortcutAction.command = row.invocation;
      shortcutAction.restart();
      return;
    }
    if (mode === "apps") row.app.execute();
    else Quickshell.execDetached(["bash", "-o", "pipefail", "-c", 'printf "%s\\n" "$1" | cliphist decode | wl-copy', "clipboard", row.id]);
    visible = false;
  }
  implicitWidth: 620
  implicitHeight: 510
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
  WlrLayershell.namespace: "quickshell-menu"
  HyprlandFocusGrab { windows: [menu]; active: menu.visible; onCleared: menu.visible = false }
  Timer {
    id: shortcutAction
    property var command: []
    // Give Hyprland time to restore focus before window actions run.
    interval: 150
    onTriggered: Quickshell.execDetached(command)
  }
  Process {
    id: clipboard
    command: ["cliphist", "list"]
    stdout: StdioCollector {
      onStreamFinished: {
        if (menu.mode === "clipboard") menu.rows = text.split("\n").filter(Boolean).map(line => ({id: line.split("\t")[0], label: line.slice(line.indexOf("\t") + 1)}));
      }
    }
  }
  Process {
    id: bindings
    command: ["hyprctl", "binds", "-j"]
    onExited: exitCode => {
      if (menu.mode === "keybinds" && exitCode !== 0)
        menu.loadError = "Tastenkürzel konnten nicht geladen werden.";
    }
    stdout: StdioCollector {
      onStreamFinished: {
        if (menu.mode !== "keybinds") return;
        try {
          menu.rows = Keybinds.rows(JSON.parse(text));
        } catch (e) {
          menu.loadError = "Tastenkürzel konnten nicht gelesen werden.";
          console.warn("Keybindings:", e);
        }
      }
    }
  }
  Rectangle {
    anchors.fill: parent
    color: Theme.base
    radius: Theme.cornerRadius
    border { width: Theme.borderWidth; color: Theme.accent }
    Column {
      anchors { fill: parent; margins: 22 }
      spacing: 14
      Text {
        text: menu.mode === "apps" ? "Anwendungen" : (menu.mode === "clipboard" ? "Zwischenablage" : "Tastenkürzel")
        color: Theme.accent
        font { family: "Iosevka Nerd Font"; pixelSize: Math.round(22 * Theme.fontScale); bold: true }
      }
      TextField {
        id: search
        objectName: "launcherSearch"
        width: parent.width
        placeholderText: menu.mode === "keybinds" ? "Nach App, Befehl oder Aktion suchen …" : "Suchen …"
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
        onTextChanged: list.currentIndex = 0
        Keys.onEscapePressed: menu.visible = false
        Keys.onDownPressed: list.currentIndex = Math.min(list.count - 1, list.currentIndex + 1)
        Keys.onUpPressed: list.currentIndex = Math.max(0, list.currentIndex - 1)
        onAccepted: menu.choose(list.currentIndex)
      }
      ListView {
        id: list
        width: parent.width
        height: 340
        clip: true
        model: menu.results
        currentIndex: 0
        spacing: 4
        onModelChanged: currentIndex = 0
        delegate: Rectangle {
          id: row
          required property var modelData
          required property int index
          width: list.width
          height: Math.max(52, rowContent.implicitHeight + 16)
          radius: Theme.controlRadius
          color: ListView.isCurrentItem ? Theme.surfaceHover : (hover.containsMouse ? Theme.surface : "transparent")
          Row {
            anchors { left: parent.left; right: parent.right; margins: 10; verticalCenter: parent.verticalCenter }
            spacing: 10
            Image {
              id: appIcon
              source: menu.mode === "apps" ? (row.modelData.app.icon.startsWith('/') || row.modelData.app.icon.startsWith('file:') ? row.modelData.app.icon : Quickshell.iconPath(row.modelData.app.icon, true)) : ""
              visible: source !== ""
              width: visible ? 24 : 0
              height: visible ? 24 : 0
              sourceSize: Qt.size(24, 24)
              fillMode: Image.PreserveAspectFit
            }
            Column {
              id: rowContent
              width: parent.width - appIcon.width - parent.spacing
              anchors.verticalCenter: parent.verticalCenter
              spacing: 4
              Text {
                width: parent.width
                text: row.modelData.label
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: Theme.text
                font.family: "Iosevka Nerd Font"
                font.pixelSize: Math.round(16 * Theme.fontScale)
              }
              Text {
                width: parent.width
                visible: menu.mode === "keybinds"
                text: row.modelData.shortcut || ""
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                color: Theme.accent
                font { family: "Iosevka Nerd Font"; pixelSize: Math.round(14 * Theme.fontScale); bold: true }
              }
            }
          }
          MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
              if (menu.mode === "keybinds") {
                list.currentIndex = row.index;
                search.forceActiveFocus();
              } else menu.choose(row.index);
            }
          }
          ToolTip {
            visible: hover.containsMouse && menu.mode === "keybinds"
            delay: 600
            text: row.modelData.detail || ""
            font.family: "Iosevka Nerd Font"
          }
        }
        Text { anchors.centerIn: parent; visible: list.count === 0; text: menu.loadError || (bindings.running ? "Lade Tastenkürzel …" : "Keine Einträge"); color: Theme.mutedText; font.family: "Iosevka Nerd Font" }
      }
      Text { text: menu.mode === "keybinds" ? list.count + " Treffer    ↑ ↓ auswählen    Enter ausführen    Esc schließen" : "↑ ↓ auswählen    Enter öffnen    Esc schließen"; color: Theme.mutedText; font.family: "Iosevka Nerd Font"; font.pixelSize: Math.round(13 * Theme.fontScale) }
    }
  }
}
