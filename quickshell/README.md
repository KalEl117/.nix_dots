# Quickshell-Desktop

Eigene Quickshell-Konfiguration für Hyprland mit Catppuccin-Mocha-Farben.
Home Manager installiert sie als `desktop`; der Dienst `quickshell.service`
startet mit `hyprland-session.target`.

## Bedienung

- `Super+Leertaste`: Anwendungen suchen und starten.
- `Super+Shift+V`: bestehende Cliphist-Zwischenablage durchsuchen.
- `Super+Ctrl+K`: aktuelle Hyprland-Tastenkürzel anzeigen.
  Aktion suchen, mit Pfeiltasten oder Mausklick markieren und mit Enter ausführen.
  Das Menü schließt sich vor der Ausführung; das Kürzel steht unter der Aktion.
- `Super+X`: Powermenü mit Sperren, Standby, Abmelden, Neustart, Ausschalten.
- Menü: Pfeiltasten, Enter, Escape oder Mausklick; Klick außerhalb schließt es.
- Polkit: Berechtigungsabfragen (z. B. 1Password, Thunar) erscheinen als
  minimaler, thematisierter Dialog. Passwort mit Enter bestätigen, Esc abbrechen.
- Leiste: NixOS-Symbol öffnet das Menü, Workspaces sind anklickbar.
- Anzeige (Monitorsymbol): Skalierung (Hyprland) und Schriftgröße (GTK-Apps +
  Quickshell-Oberfläche) in Echtzeit anpassen; Änderungen bleiben erhalten und
  werden beim Start wieder angewendet. Zurücksetzen auf Standard (125 % / 1.00×).
- Auge: automatisches Einschlafen verhindern, solange die Leiste sichtbar ist.
- Lautstärke: Mausrad ändert sie, Klick öffnet den integrierten Audiomixer.
  Prozentanzeige und Stummschaltung reagieren direkt auf PipeWire-Ereignisse,
  auch bei Änderungen per Tastatur oder in anderen Anwendungen.
  Die Reiter Wiedergabe, Aufnahme, Ausgänge, Eingänge und Profile bieten
  App-Routing (auch Aufnahme von Monitorquellen), Stummschaltung,
  Standardgeräte, Port- und Kartenprofilwahl sowie gekoppelte oder einzelne
  Kanalregler bis 153 %. Unter Erweitert stehen Latenzversatz und bei
  unterstützten Digitalausgängen Passthrough-Formate bereit. Kanalregler
  erlauben auch Balance und Surround-Verteilung. Nicht angeschlossene Ports
  und nicht verfügbare Profile sind entsprechend markiert.
  Der Mixer liest per `pactl` die PulseAudio-Schnittstelle von PipeWire aus;
  nur bei geöffnetem Popup wird alle 1,5 Sekunden aktualisiert.
- CPU: Klick öffnet Btop. Temperatur und Akkus erscheinen nur, wenn vorhanden.
- Benachrichtigung: Linksklick schließt sie, Rechtsklick schließt alle,
  Mittelklick ruft die Standardaktion auf, sofern vorhanden. Weitere Aktionen
  erscheinen als Schaltflächen. Kritische Meldungen bleiben bis zum Schließen.

## Dateien

- `shell.qml`: Einstieg, IPC und Bildschirme.
- `Bar.qml`, `stats.sh`: Leiste und Systemwerte.
- `Launcher.qml`: Apps, Zwischenablage und Tastenkürzel.
- `Powermenu.qml`: Systemaktionen.
- `Notifications.qml`: Benachrichtigungsserver und Popups.
- `PolkitDialog.qml`: thematisierter Polkit-Authentifizierungsdialog.
- `Chip.qml`: gemeinsame Schaltfläche.
- `AudioPopup.qml`, `ClockPopup.qml`, `MonitorPopup.qml`, `StyledSlider.qml`,
  `ActionButton.qml` — unterstützende Komponenten.
- `AudioBackend.qml`, `AudioEndpoint.qml`, `AudioChoice.qml`, `audio-state.sh`:
  Audio-Abfragen, Befehlswarteschlange und Mixer-Bedienelemente.
- `../modules/hyprland/quickshell.nix`: Home-Manager-Integration.

Hyprland-Quelldateien liegen jetzt in `../hypr/source/`. Der vorhandene Link
`~/.config/hypr -> ~/.nix_dots/hypr` bleibt bestehen. Home Manager schreibt
seine generierten Links nach `hypr/lua`, `hypr/scripts` und `hypr/hyprland.lua`;
diese dürfen nicht wieder als Konfigurationsquelle eingelesen werden.
Die bisherigen Waybar-, Mako- und Rofi-Konfigurationen bleiben als Referenz erhalten.

## Aktivierung

Nach Freigabe aus dem Repository-Verzeichnis:

```bash
sudo nixos-rebuild test -I nixos-config="$PWD/configuration.nix"
# Alte, noch laufende Autostart-Prozesse beenden:
pkill -x waybar || true
pkill -x mako || true
hyprctl reload
systemctl --user restart quickshell.service
notify-send 'Quickshell' 'Die neue Oberfläche ist aktiv.'
```

`test` ändert nicht den Boot-Standard; Home-Manager-Dateien werden dabei jedoch
ebenfalls aktiviert. Erst nach erfolgreicher Prüfung dauerhaft mit
`sudo nixos-rebuild switch -I nixos-config="$PWD/configuration.nix"` übernehmen.

Für spätere Änderungen an den hier verwalteten Quellen erneut rebuilden.
Fehlerprotokoll: `journalctl --user -u quickshell.service -b`.

API-Referenz: <https://quickshell.org/docs/v0.3.0/>.
