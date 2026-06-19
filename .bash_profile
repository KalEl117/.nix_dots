# 1. Lade ganz normal deine Aliases und Einstellungen aus der .bashrc
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# 2. Starte Hyprland automatisch NUR auf TTY1
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec Hyprland
fi
