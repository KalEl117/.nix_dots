pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Rectangle {
  id: endpoint
  required property var backend
  required property var audioData
  required property string kind
  property bool channelsLinked: true
  property bool advanced: false
  property var draftVolumes: null
  readonly property bool device: kind === "sink" || kind === "source"
  readonly property bool output: kind === "sink" || kind === "sink-input"
  readonly property var channelNames: (audioData.channel_map || "").split(",").filter(name => name.length > 0)
  readonly property var volumes: draftVolumes ?? channelNames.map(name => audioData.volume?.[name]?.value / 65536 || 0)
  readonly property bool canVolume: channelNames.length > 0 && audioData.has_volume !== false && audioData.volume_writable !== false
  readonly property bool isDefault: device && audioData.name === (output ? backend.state.info.default_sink_name : backend.state.info.default_source_name)
  readonly property var targets: output ? backend.sinks : backend.sources
  readonly property var ports: backend.entries(audioData.ports)
  readonly property var card: backend.cards.find(item =>
    (audioData.card !== undefined && String(item.index) === String(audioData.card))
    || item.name === audioData.properties?.["device.name"])
  readonly property var activePort: card?.ports?.[audioData.active_port]
  readonly property bool formatsSupported: kind === "sink" && (audioData.flags || []).indexOf("SET_FORMATS") >= 0

  onAudioDataChanged: if (!volumeDelay.running) draftVolumes = null
  implicitHeight: content.height + 24
  color: Theme.surface
  radius: Theme.controlRadius

  function setVolume(index, value) {
    const next = volumes.slice();
    if (channelsLinked) next.fill(value);
    else next[index] = value;
    draftVolumes = next;
    volumeDelay.restart();
  }

  function channelLabel(name) {
    return ({ "front-left": "Vorne links", "front-right": "Vorne rechts",
      "front-center": "Vorne Mitte", "rear-left": "Hinten links",
      "rear-right": "Hinten rechts", "rear-center": "Hinten Mitte",
      "side-left": "Seitlich links", "side-right": "Seitlich rechts",
      "lfe": "Subwoofer", "mono": "Mono" })[name] || name;
  }

  Timer {
    id: volumeDelay
    interval: 100
    onTriggered: endpoint.backend.run(["set-" + endpoint.kind + "-volume", endpoint.audioData.index].concat(endpoint.volumes.map(v => Math.round(v * 65536))), "volume-" + endpoint.kind + endpoint.audioData.index)
  }
  Component.onDestruction: {
    if (volumeDelay.running) {
      endpoint.backend.run(["set-" + endpoint.kind + "-volume", endpoint.audioData.index].concat(endpoint.volumes.map(v => Math.round(v * 65536))), "volume-" + endpoint.kind + endpoint.audioData.index);
    }
  }

  Column {
    id: content
    x: 12
    y: 12
    width: parent.width - 24
    spacing: 8

    Text {
      width: parent.width
      text: endpoint.backend.label(endpoint.audioData)
      wrapMode: Text.WordWrap
      textFormat: Text.PlainText
      color: Theme.text
      font { family: "Iosevka Nerd Font"; pixelSize: Math.round(14 * Theme.fontScale); bold: true }
    }
    Text {
      width: parent.width
      visible: !endpoint.device && text.length > 0
      text: endpoint.audioData.properties?.["media.name"] || ""
      elide: Text.ElideRight
      textFormat: Text.PlainText
      color: Theme.mutedText
      font { family: "Iosevka Nerd Font"; pixelSize: Math.round(12 * Theme.fontScale) }
    }
    Flow {
      width: parent.width
      spacing: 6
      ActionButton {
        text: endpoint.audioData.mute ? "Stumm" : "Ton an"
        active: endpoint.audioData.mute ?? false
        onClicked: endpoint.backend.run(["set-" + endpoint.kind + "-mute", endpoint.audioData.index, "toggle"])
      }
      ActionButton {
        visible: endpoint.device
        text: endpoint.isDefault ? "★ Standard" : "Als Standard"
        active: endpoint.isDefault
        onClicked: endpoint.backend.run(["set-default-" + endpoint.kind, endpoint.audioData.name])
      }
      ActionButton {
        visible: endpoint.channelNames.length > 1
        text: endpoint.channelsLinked ? "Kanäle gekoppelt" : "Kanäle einzeln"
        active: endpoint.channelsLinked
        onClicked: endpoint.channelsLinked = !endpoint.channelsLinked
      }
    }
    Repeater {
      model: endpoint.canVolume ? (endpoint.channelsLinked ? 1 : endpoint.channelNames.length) : 0
      Column {
        id: channel
        required property int index
        width: content.width
        spacing: 0
        Row {
          width: parent.width
          Text {
            width: parent.width - volumeText.width
            text: endpoint.channelsLinked ? "Lautstärke" : endpoint.channelLabel(endpoint.channelNames[channel.index])
            elide: Text.ElideRight
            color: Theme.mutedText
            font { family: "Iosevka Nerd Font"; pixelSize: Math.round(12 * Theme.fontScale) }
          }
          Text {
            id: volumeText
            text: Math.round(volumeSlider.value * 100) + "%"
            color: Theme.text
            font { family: "Iosevka Nerd Font"; pixelSize: Math.round(12 * Theme.fontScale) }
          }
        }
        StyledSlider {
          id: volumeSlider
          width: parent.width
          from: 0
          to: 1.53
          stepSize: 0.01
          value: endpoint.channelsLinked ? Math.max(0, ...endpoint.volumes) : (endpoint.volumes[channel.index] ?? 0)
          onMoved: endpoint.setVolume(channel.index, value)
        }
      }
    }
    Text {
      visible: !endpoint.canVolume
      text: "Dieser Stream stellt keine Lautstärkeregelung bereit."
      width: parent.width
      wrapMode: Text.WordWrap
      color: Theme.mutedText
      font { family: "Iosevka Nerd Font"; pixelSize: Math.round(12 * Theme.fontScale) }
    }
    AudioChoice {
      width: parent.width
      visible: !endpoint.device
      model: endpoint.targets.map(item => ({ name: String(item.index), label: endpoint.backend.label(item) }))
      selected: String(endpoint.output ? endpoint.audioData.sink : endpoint.audioData.source)
      onActivated: endpoint.backend.run(["move-" + endpoint.kind, endpoint.audioData.index, currentValue])
    }
    AudioChoice {
      width: parent.width
      visible: endpoint.device && endpoint.ports.length > 0
      model: endpoint.ports.map(port => ({ name: port.name, label: (port.description === "(null)" ? port.name : port.description || port.name) + (port.availability === "not available" ? " (nicht angeschlossen)" : "") }))
      selected: endpoint.audioData.active_port || ""
      onActivated: endpoint.backend.run(["set-" + endpoint.kind + "-port", endpoint.audioData.index, currentValue])
    }
    ActionButton {
      visible: endpoint.device && (endpoint.activePort !== undefined || endpoint.formatsSupported)
      text: endpoint.advanced ? "Erweitert ▴" : "Erweitert ▾"
      active: endpoint.advanced
      onClicked: endpoint.advanced = !endpoint.advanced
    }
    Column {
      width: parent.width
      visible: endpoint.advanced
      spacing: 8
      Text {
        text: "Latenzversatz (ms)"
        visible: endpoint.activePort !== undefined
        color: Theme.mutedText
        font { family: "Iosevka Nerd Font"; pixelSize: Math.round(12 * Theme.fontScale) }
      }
      Row {
        width: parent.width
        visible: endpoint.activePort !== undefined
        spacing: 8
        TextField {
          id: latency
          width: parent.width - applyLatency.width - 8
          text: String(parseFloat(endpoint.activePort?.latency_offset || "0") / 1000)
          validator: DoubleValidator { bottom: -2000; top: 5000; decimals: 2; locale: "C" }
          color: Theme.text
          placeholderText: "0.00"
          background: Rectangle { color: Theme.base; radius: 6 }
          onAccepted: if (acceptableInput) applyLatency.clicked()
        }
        ActionButton {
          id: applyLatency
          text: "Übernehmen"
          enabled: latency.acceptableInput
          onClicked: endpoint.backend.run(["set-port-latency-offset", endpoint.card.index, endpoint.audioData.active_port, Math.round(Number(latency.text) * 1000)])
        }
      }
      Text {
        visible: endpoint.formatsSupported
        width: parent.width
        text: "Digitale Formate / Passthrough"
        color: Theme.mutedText
        font { family: "Iosevka Nerd Font"; pixelSize: Math.round(12 * Theme.fontScale) }
      }
      Flow {
        id: formatsFlow
        width: parent.width
        visible: endpoint.formatsSupported
        spacing: 6
        Repeater {
          model: ["ac3-iec61937", "eac3-iec61937", "dts-iec61937", "mpeg-iec61937", "mpeg2-aac-iec61937", "truehd-iec61937", "dtshd-iec61937"]
          ActionButton {
            required property string modelData
            text: modelData.replace("-iec61937", "").toUpperCase()
            active: (endpoint.audioData.formats || []).some(format => format.split(",")[0].trim() === modelData)
            onClicked: {
              let formats = (endpoint.audioData.formats || ["pcm"]).slice();
              if (active) formats = formats.filter(format => format.split(",")[0].trim() !== modelData);
              else formats.push(modelData);
              endpoint.backend.run(["set-sink-formats", endpoint.audioData.index, formats.join(";")]);
            }
          }
        }
      }
      Text {
        visible: endpoint.formatsSupported
        width: parent.width
        text: "Nur Formate aktivieren, die der angeschlossene Empfänger unterstützt. PCM bleibt verfügbar."
        wrapMode: Text.WordWrap
        color: Theme.mutedText
        font { family: "Iosevka Nerd Font"; pixelSize: Math.round(11 * Theme.fontScale) }
      }
    }
  }
}
