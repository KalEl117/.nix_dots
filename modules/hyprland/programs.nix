{ pkgs, ... }:

{
  home.packages = with pkgs; [
    hypridle
    hyprlock
    kitty
    thunar
    grim
    slurp
    swappy
    cliphist
    wl-clipboard
    brightnessctl
    playerctl
    udiskie
    jq
    _1password-gui
    libnotify
    # Startet ein schwebendes, an den Inhalt angepasstes Terminal mit fastfetch
    (writeShellScriptBin "sysinfo" (builtins.readFile ../../hypr/source/scripts/sysinfo.sh))
  ];

  xdg.desktopEntries.system = {
    name = "System";
    comment = "Systemdaten mit fastfetch anzeigen";
    exec = "sysinfo";
    terminal = false;
    icon = "utilities-system-monitor";
    categories = [ "System" "Utility" ];
  };
}
