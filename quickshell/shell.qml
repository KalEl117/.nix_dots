pragma ComponentBehavior: Bound
//@ pragma IconTheme Papirus-Dark
import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
  id: root
  property bool keepAwake: false
  property bool displayStarted: false

  function applyDisplaySettings() {
    if (root.displayStarted) return;
    root.displayStarted = true;
    Theme.fontScale = displaySettings.fontScale;
    Quickshell.execDetached(["hyprctl", "eval", 'hl.monitor({ output = "' + displaySettings.monitorName + '", mode = "preferred", position = "auto", scale = ' + displaySettings.scale + ' })']);
  }
  FileView {
    id: settingsFile
    path: Quickshell.stateDir + "/bar-settings.json"
    printErrors: false
    onLoadFailed: _error => setText('{"use24Hour":true,"showSeconds":false}')
    onAdapterUpdated: writeAdapter()
    JsonAdapter {
      id: barSettings
      property bool use24Hour: true
      property bool showSeconds: false
    }
  }
  FileView {
    id: displaySettingsFile
    path: Quickshell.stateDir + "/display-settings.json"
    printErrors: false
    onLoadFailed: _error => setText('{"monitorName":"DP-3","scale":1.25,"fontScale":1.0}')
    onLoaded: root.applyDisplaySettings()
    onAdapterUpdated: {
      writeAdapter();
      root.applyDisplaySettings();
    }
    JsonAdapter {
      id: displaySettings
      property string monitorName: "DP-3"
      property real scale: 1.25
      property real fontScale: 1.0
    }
  }
  Launcher { id: launcher }
  Powermenu { id: powermenu }
  PolkitDialog {}
  IpcHandler {
    target: "menu"
    function toggle(mode: string): void { launcher.toggle(mode); }
  }
  IpcHandler {
    target: "power"
    function toggle(): void { powermenu.toggle(); }
  }
  Variants {
    model: Quickshell.screens
    Bar {
      required property var modelData
      screen: modelData
      clockSettings: barSettings
      displaySettings: displaySettings
      keepAwake: root.keepAwake
      onToggleAwake: root.keepAwake = !root.keepAwake
      onOpenMenu: launcher.toggle("apps")
    }
  }
  Notifications {}
}
