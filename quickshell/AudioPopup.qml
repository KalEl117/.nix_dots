pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell

PopupWindow {
  id: popup
  required property Item anchorItem
  property string view: "sinks"
  property bool showMonitors: false
  property bool showInactive: true
  readonly property bool configuration: view === "cards"
  readonly property string kind: ({ sinks: "sink", sources: "source", playback: "sink-input", recording: "source-output" })[view] || "sink"
  readonly property var items: {
    let rows = audio[view] || [];
    if (view === "sources" && !showMonitors) rows = rows.filter(item => item.properties?.["device.class"] !== "monitor" && !item.monitor_source && (item.monitor_of_sink === null || item.monitor_of_sink === undefined || item.monitor_of_sink === 4294967295));
    if ((view === "playback" || view === "recording") && !showInactive) rows = rows.filter(item => !item.corked);
    return rows;
  }
  implicitWidth: Math.min(620, (popup.screen?.width ?? 1920) - 32)
  implicitHeight: Math.min(650, (popup.screen?.height ?? 1080) - 80)
  color: "transparent"
  grabFocus: true
  anchor {
    item: popup.anchorItem
    edges: Edges.Bottom | Edges.Right
    gravity: Edges.Bottom | Edges.Left
    adjustment: PopupAdjustment.Slide
    margins.top: 8
  }
  AudioBackend { id: audio; active: popup.visible }
  ScriptModel { id: itemModel; values: popup.items.map(item => item.index) }
  onViewChanged: list.positionViewAtBeginning()

  Rectangle {
    focus: true
    Keys.onEscapePressed: popup.visible = false
    anchors.fill: parent
    color: Theme.base
    radius: Theme.cornerRadius
    border { width: Theme.borderWidth; color: Theme.accent }
    Column {
      id: header
      anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
      spacing: 10
      Row {
        width: parent.width
        Text {
          width: parent.width - closeButton.width
          height: 34
          text: "Audio"
          color: Theme.accent
          verticalAlignment: Text.AlignVCenter
          font { family: "Iosevka Nerd Font"; pixelSize: Math.round(20 * Theme.fontScale); bold: true }
        }
        ActionButton { id: closeButton; text: "✕"; compact: true; onClicked: popup.visible = false }
      }
      Flow {
        width: parent.width
        spacing: 6
        Repeater {
          model: [
            { name: "playback", label: "Wiedergabe" },
            { name: "recording", label: "Aufnahme" },
            { name: "sinks", label: "Ausgänge" },
            { name: "sources", label: "Eingänge" },
            { name: "cards", label: "Profile" }
          ]
          ActionButton {
            required property var modelData
            text: modelData.label
            active: popup.view === modelData.name
            onClicked: popup.view = modelData.name
          }
        }
      }
      ActionButton {
        visible: popup.view === "sources" || popup.view === "playback" || popup.view === "recording"
        text: popup.view === "sources" ? "Monitorquellen anzeigen" : "Auch inaktive Streams anzeigen"
        active: popup.view === "sources" ? popup.showMonitors : popup.showInactive
        onClicked: {
          if (popup.view === "sources") popup.showMonitors = !popup.showMonitors;
          else popup.showInactive = !popup.showInactive;
        }
      }
      Text {
        width: parent.width
        visible: audio.error.length > 0
        text: audio.error
        textFormat: Text.PlainText
        wrapMode: Text.WrapAnywhere
        maximumLineCount: 3
        elide: Text.ElideRight
        color: Theme.critical
        font { family: "Iosevka Nerd Font"; pixelSize: Math.round(12 * Theme.fontScale) }
      }
    }
    ListView {
      id: list
      anchors { top: header.bottom; bottom: footer.top; left: parent.left; right: parent.right; margins: 16 }
      spacing: 10
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      model: itemModel
      ScrollBar.vertical: ScrollBar {}
      delegate: Loader {
        id: entry
        required property var modelData
        readonly property var row: popup.items.find(item => item.index === modelData) || ({})
        width: list.width - 12
        sourceComponent: popup.configuration ? cardComponent : endpointComponent
        Component {
          id: endpointComponent
          AudioEndpoint { width: entry.width; backend: audio; audioData: entry.row; kind: popup.kind }
        }
        Component {
          id: cardComponent
          Rectangle {
            width: entry.width
            implicitHeight: cardContent.height + 24
            color: Theme.surface
            radius: Theme.controlRadius
            Column {
              id: cardContent
              x: 12
              y: 12
              width: parent.width - 24
              spacing: 10
              Text {
                width: parent.width
                text: audio.label(entry.row)
                wrapMode: Text.WordWrap
                textFormat: Text.PlainText
                color: Theme.text
                font { family: "Iosevka Nerd Font"; pixelSize: Math.round(14 * Theme.fontScale); bold: true }
              }
              AudioChoice {
                width: parent.width
                model: audio.entries(entry.row.profiles).map(profile => ({ name: profile.name, label: profile.description + (profile.available === false ? " (nicht verfügbar)" : "") }))
                selected: entry.row.active_profile || ""
                onActivated: audio.run(["set-card-profile", entry.row.index, currentValue])
              }
            }
          }
        }
      }
      Text {
        anchors.centerIn: parent
        width: parent.width - 24
        visible: popup.items.length === 0
        text: ({ playback: "Keine Wiedergabe-Streams vorhanden.", recording: "Keine Aufnahme-Streams vorhanden.", sinks: "Keine Ausgabegeräte vorhanden.", sources: "Keine Eingabegeräte vorhanden. Prüfe gegebenenfalls das Kartenprofil.", cards: "Keine Audiokarten vorhanden." })[popup.view]
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        color: Theme.mutedText
        font { family: "Iosevka Nerd Font"; pixelSize: Math.round(13 * Theme.fontScale) }
      }
    }
    Text {
      id: footer
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 16 }
      text: "100 % = unverstärkt · bis 153 % regelbar"
      color: Theme.mutedText
      font { family: "Iosevka Nerd Font"; pixelSize: Math.round(11 * Theme.fontScale) }
    }
  }
}
