pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Polkit

Scope {
  PolkitAgent {
    id: agent
    onAuthenticationRequestStarted: dialog.begin(currentFlow)
  }

  readonly property var currentFlow: agent.flow

  PanelWindow {
    id: dialog
    visible: agent.isActive && agent.flow !== null
    screen: Hyprland.focusedMonitor ? Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor.name) : Quickshell.screens[0]
    implicitWidth: 440
    implicitHeight: Math.max(240, card.implicitHeight + 40)
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-polkit"
    HyprlandFocusGrab { windows: [dialog]; active: dialog.visible; onCleared: dialog.cancel() }
    Timer {
      running: dialog.visible
      interval: 150
      repeat: false
      onTriggered: if (agent.flow?.isResponseRequired) input.forceActiveFocus()
    }

    function begin(flow) {
      input.text = "";
      input.forceActiveFocus();
    }
    function submit() {
      const flow = agent.flow;
      if (flow && flow.isResponseRequired) {
        flow.submit(input.text);
        input.text = "";
      }
    }
    function cancel() {
      const flow = agent.flow;
      if (flow && !flow.isCompleted) flow.cancelAuthenticationRequest();
    }

    Connections {
      target: agent.flow
      function onIsResponseRequiredChanged() {
        if (agent.flow && agent.flow.isResponseRequired) {
          input.text = "";
          input.forceActiveFocus();
        }
      }
    }

    Rectangle {
      anchors.fill: parent
      color: Theme.base
      radius: Theme.cornerRadius
      border { width: Theme.borderWidth; color: Theme.accent }
      Column {
        id: card
        anchors { fill: parent; margins: 20 }
        spacing: 12
        Row {
          width: parent.width
          spacing: 10
          Image {
            source: agent.flow?.iconName && Quickshell.iconPath(agent.flow.iconName, true) !== "" ? Quickshell.iconPath(agent.flow.iconName) : "assets/lock.svg"
            sourceSize { width: 26; height: 26 }
            anchors.verticalCenter: parent.verticalCenter
          }
          Text {
            width: parent.width - 36
            text: agent.flow?.message ?? "Berechtigung erforderlich"
            color: Theme.text
            font { family: "Iosevka Nerd Font"; pixelSize: Math.round(17 * Theme.fontScale); bold: true }
            wrapMode: Text.Wrap
            textFormat: Text.PlainText
            verticalAlignment: Text.AlignVCenter
          }
        }
        Flow {
          visible: (agent.flow?.identities ?? []).length > 1
          width: parent.width
          spacing: 6
          Repeater {
            model: agent.flow?.identities ?? []
            Chip {
              required property var modelData
              text: modelData.displayName || modelData.string
              selected: agent.flow && agent.flow.selectedIdentity === modelData
              onClicked: { if (agent.flow) agent.flow.selectedIdentity = modelData; }
            }
          }
        }
        Text {
          visible: (agent.flow?.supplementaryMessage ?? "") !== ""
          width: parent.width
          text: agent.flow?.supplementaryMessage ?? ""
          color: agent.flow?.supplementaryIsError ? Theme.critical : Theme.mutedText
          font { family: "Iosevka Nerd Font"; pixelSize: Math.round(13 * Theme.fontScale) }
          wrapMode: Text.Wrap
          textFormat: Text.PlainText
        }
        Text {
          visible: agent.flow && !agent.flow.isResponseRequired
          width: parent.width
          text: "Authentifizierung läuft …"
          color: Theme.mutedText
          font.family: "Iosevka Nerd Font"
          font.pixelSize: Math.round(14 * Theme.fontScale)
        }
        Item {
          width: parent.width
          height: input.visible ? input.implicitHeight : 1
          TextField {
            id: input
            visible: agent.flow?.isResponseRequired ?? false
            width: parent.width
            echoMode: (agent.flow?.responseVisible ?? false) ? TextField.Normal : TextField.Password
            placeholderText: agent.flow?.inputPrompt ?? "Passwort"
            placeholderTextColor: Theme.mutedText
            selectionColor: Theme.accent
            selectedTextColor: Theme.base
            color: Theme.text
            font { family: "Iosevka Nerd Font"; pixelSize: Math.round(17 * Theme.fontScale) }
            background: Rectangle {
              color: Theme.crust
              radius: Theme.controlRadius
              border { width: 1; color: input.activeFocus ? Theme.accent : Theme.surfaceHover }
            }
            onAccepted: dialog.submit()
            Keys.onEscapePressed: dialog.cancel()
          }
        }
        RowLayout {
          spacing: 12
          Text {
            Layout.fillWidth: true
            text: "Enter bestätigen    Esc abbrechen"
            color: Theme.mutedText
            font { family: "Iosevka Nerd Font"; pixelSize: Math.round(12 * Theme.fontScale) }
          }
          Chip { text: "Abbrechen"; onClicked: dialog.cancel() }
          ActionButton { text: "Bestätigen"; active: input.visible; onClicked: dialog.submit() }
        }
      }
    }
  }
}