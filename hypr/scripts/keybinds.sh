#!/usr/bin/env bash

# Pfad zu deiner Hyprland-Konfiguration
CONFIG_FILE="$HOME/.config/hypr/hyprland.conf"

# Falls du deine Binds in einer separaten Datei hast (z.B. keybinds.conf):
# CONFIG_FILE="$HOME/.config/hypr/keybinds.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    notify-send "Hyprland Keybinds" "Konfigurationsdatei nicht gefunden!"
    exit 1
fi
# 1. Binds filtern und $mainMod durch SUPER ersetzen
# 2. Per awk formatieren & aufräumen
grep -E '^\s*bind[a-z]*\s*=' "$CONFIG_FILE" | \
sed -E 's/^\s*bind[a-z]*\s*=\s*//' | \
sed 's/\$mainMod/SUPER/g' | \
awk -F ',' '{
    # Trim Whitespaces
    gsub(/^[ \t]+|[ \t]+$/, "", $1); # Modifiers
    gsub(/^[ \t]+|[ \t]+$/, "", $2); # Key
    gsub(/^[ \t]+|[ \t]+$/, "", $3); # Dispatcher / Action
    gsub(/^[ \t]+|[ \t]+$/, "", $4); # Command / Argument

    # Taste aufbauen
    key = ($1 != "") ? $1 " + " $2 : $2;

    # Aktion hübsch aufbereiten
    action = "";

    if ($3 == "exec") {
        # Befehl auspfadieren: Nur den eigentlichen Programmnamen nehmen (erstes Wort)
        split($4, cmd_parts, " ");
        # Pfad-Präfixe wie ~/.config/hypr/scripts/ entfernen
        sub(".*/", "", cmd_parts[1]);
        action = cmd_parts[1];
    } else if ($3 == "killactive") {
        action = "Fenster schließen";
    } else if ($3 == "togglefloating") {
        action = "Floating Modus umschalten";
    } else if ($3 == "fullscreen") {
        action = "Vollbild umschalten";
    } else if ($3 == "workspace") {
        action = "Wechsle zu Workspace " $4;
    } else if ($3 == "movetoworkspace") {
        action = "Verschiebe zu Workspace " $4;
    } else {
        # Falls es ein sonstiger Dispatcher ist (z. B. pseudo, changegroup)
        action = ($4 != "") ? $3 " (" $4 ")" : $3;
    }

    # Sauber ausgerichtet ausgeben (Tab-getrennt für schöne Rofi-Spalten)
    printf "%-22s \t→  %s\n", key, action
}' | \
rofi -dmenu -i -p "Hyprland Binds" -theme-str 'window {width: 40%;}'
