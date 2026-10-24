pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland

PopupWindow {
  id: popup
  required property Item anchorItem
  required property var settings
  required property var monitor
  readonly property string monitorName: popup.monitor?.name ?? "DP-3"
  readonly property real defaultScale: 1.25

  readonly property var scaleModes: {
    const w = popup.monitor?.width ?? 2560;
    const h = popup.monitor?.height ?? 1440;
    const candidates = [1.0, 1.1, 1.12, 1.125, 1.2, 1.25, 1.333, 1.4, 1.5, 1.6, 1.666, 1.75, 1.8, 2.0, 2.25, 2.5, 3.0];
    const modes = [];
    for (const c of candidates) {
      const scaledWidth = w / c;
      const scaledHeight = h / c;
      if (Math.abs(scaledWidth - Math.round(scaledWidth)) < 1e-4 && Math.abs(scaledHeight - Math.round(scaledHeight)) < 1e-4) {
        modes.push(c);
      }
    }
    return modes;
  }

  function applyScale(value) {
    popup.settings.scale = value;
    popup.settings.monitorName = popup.monitorName;
    const cmd = "hl.monitor({ output = \"" + popup.monitorName +
      "\", mode = \"preferred\", position = \"auto\", scale = " + value.toFixed(2) + " })";
    Quickshell.execDetached(["hyprctl", "eval", cmd]);
    Hyprland.refreshMonitors();
  }

  function applyFont(value) {
    popup.settings.fontScale = value;
    Theme.fontScale = value;
    Quickshell.execDetached(["dconf", "write", "/org/gnome/desktop/interface/text-scaling-factor", value.toFixed(3)]);
  }

  function resetScale() {
    popup.applyScale(popup.defaultScale);
  }

  function resetFont() {
    popup.applyFont(1.0);
  }

  implicitWidth: 380
  implicitHeight: 350
  color: "transparent"
  grabFocus: true
  anchor {
    item: popup.anchorItem
    edges: Edges.Bottom | Edges.Right
    gravity: Edges.Bottom | Edges.Left
    adjustment: PopupAdjustment.Slide
    margins.top: 8
  }

  Rectangle {
    anchors.fill: parent
    color: Theme.base
    radius: Theme.cornerRadius
    border { width: Theme.borderWidth; color: Theme.accent }

    Column {
      anchors { fill: parent; margins: 18 }
      spacing: 14

      Row {
        width: parent.width
        spacing: 8
        Text {
          width: parent.width - resetAll.width
          height: 34
          verticalAlignment: Text.AlignVCenter
          elide: Text.ElideRight
          text: "Anzeige"
          color: Theme.accent
          font { family: "Iosevka Nerd Font"; pixelSize: Math.round(20 * Theme.fontScale); bold: true }
        }
        ActionButton {
          id: resetAll
          text: "Standard"
          onClicked: {
            popup.resetScale();
            popup.resetFont();
          }
        }
      }

      Column {
        width: parent.width
        spacing: 6
        Row {
          width: parent.width
          Text {
            width: parent.width - currentScale.width
            text: "Skalierung"
            elide: Text.ElideRight
            color: Theme.text
            font { family: "Iosevka Nerd Font"; pixelSize: Math.round(14 * Theme.fontScale); bold: true }
          }
          Text {
            id: currentScale
            text: Math.round(popup.settings.scale * 100) + "%"
            color: Theme.mutedText
            font { family: "Iosevka Nerd Font"; pixelSize: Math.round(13 * Theme.fontScale) }
          }
        }
        Grid {
          id: scaleGrid
          width: parent.width
          columns: 3
          spacing: 6
          Repeater {
            model: popup.scaleModes
            ActionButton {
              required property real modelData
              width: (scaleGrid.width - scaleGrid.spacing * (scaleGrid.columns - 1)) / scaleGrid.columns
              text: Math.round(modelData * 100) + "%"
              active: Math.abs(popup.settings.scale - modelData) < 0.005
              onClicked: popup.applyScale(modelData)
            }
          }
        }
      }

      Column {
        width: parent.width
        spacing: 6
        Row {
          width: parent.width
          Text {
            width: parent.width - fontValue.width
            text: "Schriftgröße"
            elide: Text.ElideRight
            color: Theme.text
            font { family: "Iosevka Nerd Font"; pixelSize: Math.round(14 * Theme.fontScale); bold: true }
          }
          Text {
            id: fontValue
            text: fontSlider.value.toFixed(2) + "×"
            color: Theme.mutedText
            font { family: "Iosevka Nerd Font"; pixelSize: Math.round(13 * Theme.fontScale) }
          }
        }
        StyledSlider {
          id: fontSlider
          width: parent.width
          from: 0.9
          to: 1.5
          stepSize: 0.05
          value: popup.settings.fontScale
          onMoved: popup.applyFont(value)
        }
        ActionButton {
          width: parent.width - 92
          anchors.horizontalCenter: parent.horizontalCenter
          text: "Reset auf 1.00×"
          onClicked: { fontSlider.value = 1.0; popup.resetFont(); }
        }
      }

      Text {
        width: parent.width
        text: "Skalierung übernimmt Hyprland; Einstellungen bleiben erhalten."
        color: Theme.mutedText
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font { family: "Iosevka Nerd Font"; pixelSize: Math.round(12 * Theme.fontScale) }
      }
    }
  }
}
