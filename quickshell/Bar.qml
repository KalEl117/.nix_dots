import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
  id: bar
  property bool keepAwake: false
  required property var clockSettings
  required property var displaySettings
  signal toggleAwake()
  signal openMenu()
  property var stats: ({})
  readonly property var audioSink: Pipewire.defaultAudioSink
  function togglePopup(name) {
    if (name === "audio") {
      clockPopup.visible = false;
      displayPopup.visible = false;
      audioPopup.visible = !audioPopup.visible;
    } else if (name === "clock") {
      audioPopup.visible = false;
      displayPopup.visible = false;
      clockPopup.visible = !clockPopup.visible;
    } else if (name === "display") {
      audioPopup.visible = false;
      clockPopup.visible = false;
      displayPopup.visible = !displayPopup.visible;
    }
  }
  anchors { top: true; left: true; right: true }
  implicitHeight: 42
  color: Theme.translucentBase
  WlrLayershell.namespace: "quickshell-bar"
  IdleInhibitor { window: bar; enabled: bar.keepAwake }
  PwObjectTracker { objects: [bar.audioSink] }
  SystemClock { id: clock; precision: bar.clockSettings.showSeconds ? SystemClock.Seconds : SystemClock.Minutes }
  Process {
    id: poll
    command: ["bash", Quickshell.shellPath("stats.sh")]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        try { bar.stats = JSON.parse(text); } catch (e) { console.warn("Stats:", e); }
      }
    }
  }
  Timer { interval: 3000; running: true; repeat: true; onTriggered: poll.running = true }
  Row {
    id: left
    anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
    spacing: 4
    Chip { text: "󱄅"; onClicked: bar.openMenu() }
    Repeater {
      model: Hyprland.workspaces
      Chip {
        required property var modelData
        visible: modelData.id > 0
        text: modelData.name
        selected: modelData.focused
        onClicked: modelData.activate()
      }
    }
  }
  Text {
    anchors.centerIn: parent
    width: Math.max(0, parent.width - 2 * Math.max(left.width + 25, right.width + 25))
    horizontalAlignment: Text.AlignHCenter
    elide: Text.ElideRight
    color: Theme.text
    font.family: "Iosevka Nerd Font"
    font.pixelSize: Math.round(15 * Theme.fontScale)
    textFormat: Text.PlainText
    text: Hyprland.activeToplevel?.title ?? ""
  }
  Row {
    id: right
    anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
    spacing: 4
    Chip { text: bar.keepAwake ? "" : ""; selected: bar.keepAwake; onClicked: bar.toggleAwake() }
    Chip {
      id: audioChip
      text: !bar.audioSink?.audio ? " —"
        : bar.audioSink.audio.muted ? ""
        : " " + Math.round(bar.audioSink.audio.volume * 100) + "%"
      selected: audioPopup.visible
      onClicked: bar.togglePopup("audio")
      onScrolled: delta => Quickshell.execDetached(["wpctl", "set-volume", "-l", "1", "@DEFAULT_AUDIO_SINK@", delta > 0 ? "5%+" : "5%-"])
    }
    Chip { text: " " + (bar.stats.cpu ?? "—") + "%"; onClicked: Quickshell.execDetached(["kitty", "-e", "btop"]) }
    Chip { text: " " + (bar.stats.memory ?? "—") + "%" }
    Chip { visible: bar.stats.temperature !== undefined; text: " " + (bar.stats.temperature ?? "") + "°C" }
    Repeater {
      model: bar.stats.batteries ?? []
      Chip { required property var modelData; text: modelData }
    }
    Chip {
      id: displayChip
      text: "󰍹"
      selected: displayPopup.visible
      onClicked: bar.togglePopup("display")
    }
    Chip {
      id: clockChip
      text: Qt.formatDateTime(clock.date, bar.clockSettings.use24Hour ? (bar.clockSettings.showSeconds ? "HH:mm:ss | d. MMMM" : "HH:mm | d. MMMM") : (bar.clockSettings.showSeconds ? "hh:mm:ss AP | d. MMMM" : "hh:mm AP | d. MMMM"))
      selected: clockPopup.visible
      onClicked: bar.togglePopup("clock")
    }
  }

  AudioPopup { id: audioPopup; anchorItem: audioChip }
  ClockPopup { id: clockPopup; anchorItem: clockChip; settings: bar.clockSettings }
  MonitorPopup { id: displayPopup; anchorItem: displayChip; settings: bar.displaySettings; monitor: Hyprland.monitorFor(bar.screen) }
}
