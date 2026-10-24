pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: backend
  property bool active: false
  property var state: ({ objects: {}, info: {} })
  property string readFailure: ""
  property string writeFailure: ""
  readonly property string error: writeFailure || readFailure
  property string readError: ""
  property bool readValid: false
  property string commandError: ""
  property var pending: []
  readonly property bool busy: writer.running || pending.length > 0
  readonly property var sinks: state.objects.sinks ?? []
  readonly property var sources: state.objects.sources ?? []
  readonly property var playback: state.objects.sink_inputs ?? []
  readonly property var recording: state.objects.source_outputs ?? []
  readonly property var cards: state.objects.cards ?? []

  onActiveChanged: if (active) refresh()

  function refresh() {
    if (active && !reader.running && !busy) {
      readError = "";
      readValid = false;
      reader.running = true;
    }
  }

  function run(args, key) {
    // Coalesce slider changes, but keep routing/profile changes in order.
    const queue = pending.filter(job => !key || job.key !== key);
    queue.push({ args: args.map(String), key: key || "" });
    pending = queue;
    dispatch();
  }

  function dispatch() {
    if (writer.running || pending.length === 0) return;
    const queue = pending.slice();
    const job = queue.shift();
    pending = queue;
    commandError = "";
    writeFailure = "";
    writer.command = ["pactl"].concat(job.args);
    writer.running = true;
  }

  function entries(value) {
    if (Array.isArray(value)) return value;
    return Object.keys(value || {}).map(name => Object.assign({ name: name }, value[name]));
  }

  function label(item) {
    return item.description || item.properties?.["application.name"] || item.properties?.["device.description"] || item.name || ("Stream " + item.index);
  }

  Process {
    id: reader
    command: ["bash", Quickshell.shellPath("audio-state.sh")]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const next = JSON.parse(text);
          if (!next.objects || !next.info) throw new Error("Unvollständige Audio-Daten");
          backend.readValid = true;
          // Avoid rebuilding delegates on every timer tick.
          if (JSON.stringify(next) !== JSON.stringify(backend.state)) backend.state = next;
        } catch (e) { backend.readError = "Audio-Daten konnten nicht gelesen werden."; }
      }
    }
    stderr: StdioCollector { onStreamFinished: if (text.trim()) backend.readError = text.trim() }
    onExited: (code, status) => {
      if (code !== 0 || status !== 0 || !backend.readValid) backend.readFailure = backend.readError || "Audio-Server nicht erreichbar (pactl).";
      else backend.readFailure = "";
    }
  }

  Process {
    id: writer
    stderr: StdioCollector { onStreamFinished: backend.commandError = text.trim() }
    onExited: (code, status) => {
      backend.writeFailure = code === 0 && status === 0 ? "" : (backend.commandError || "Audio-Einstellung konnte nicht übernommen werden.");
      if (backend.pending.length > 0) Qt.callLater(backend.dispatch);
      else refreshDelay.restart();
    }
  }
  Timer { id: refreshDelay; interval: 150; onTriggered: backend.refresh() }
  Timer { interval: 1500; running: backend.active; repeat: true; onTriggered: backend.refresh() }
}
