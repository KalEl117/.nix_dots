-- Autostart-Prozesse werden nur beim Start der Hyprland-Sitzung ausgeführt.
hl.on("hyprland.start", function()
  hl.exec_cmd("hypridle")
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd(
    "awww img /home/zoltan/.config/hypr/nix-wallpaper-nineish-catppuccin-mocha-alt.png --transition-type none"
  )
  hl.exec_cmd("systemctl --user start hyprland-session.target")
  hl.exec_cmd("udiskie")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
  hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

  -- hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'catppuccin-mocha-mauve-standard+rimless'")
  -- hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme 'Catppuccin-Mocha-Mauve'")
  -- hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
end)
