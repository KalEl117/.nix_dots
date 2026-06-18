#!/usr/bin/env bash

# Abbrechen bei Fehlern
set -e

echo "=== SSH Setup Skript für NixOS ==="

# 1. E-Mail-Adresse für den Schlüssel abfragen
read -p "Bitte gib deine GitHub E-Mail-Adresse ein: " EMAIL

# 2. SSH-Schlüssel generieren (Ed25519 ist der aktuelle Standard)
SSH_KEY="$HOME/.ssh/id_ed25519"

if [ -f "$SSH_KEY" ]; then
    echo "⚠️ Ein Schlüssel unter $SSH_KEY existiert bereits!"
    read -p "Möchtest du ihn überschreiben? (y/N): " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        echo "Abgebrochen. Nutze bestehenden Schlüssel."
    else
        rm "$SSH_KEY" "$SSH_KEY.pub"
        ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY"
    fi
else
    echo "Generiere neuen Ed25519 SSH-Schlüssel..."
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY"
fi

# 3. SSH-Agenten im Hintergrund starten
echo "Starte SSH-Agenten..."
eval "$(ssh-agent -s)"

# 4. Schlüssel zum Agenten hinzufügen
echo "Füge Schlüssel zum Agenten hinzu..."
ssh-add "$SSH_KEY"

# 5. Öffentlichen Schlüssel in die Zwischenablage kopieren
echo "Kopiere öffentlichen Schlüssel in die Zwischenablage..."

if [ "$XDG_SESSION_TYPE" = "wayland" ] && command -v wl-copy &> /dev/null; then
    wl-copy < "${SSH_KEY}.pub"
    echo "📋 Key wurde via 'wl-copy' in die Wayland-Zwischenablage kopiert!"
elif command -v xclip &> /dev/null; then
    xclip -selection clipboard < "${SSH_KEY}.pub"
    echo "📋 Key wurde via 'xclip' in die Zwischenablage kopiert!"
elif command -v xsel &> /dev/null; then
    xsel --clipboard --input < "${SSH_KEY}.pub"
    echo "📋 Key wurde via 'xsel' in die Zwischenablage kopiert!"
else
    echo "❌ Fehler: Kein Tool für die Zwischenablage gefunden (wl-copy, xclip oder xsel)."
    echo "Hier ist dein Key zum manuellen Kopieren:"
    cat "${SSH_KEY}.pub"
fi

echo "--------------------------------------------------"
echo "Fertig! Du kannst den Key jetzt direkt bei GitHub einfügen."
echo "Link: https://github.com/settings/keys"
echo "--------------------------------------------------"
