{ ... }:

{
  imports = [
    ./programs.nix
    ./quickshell.nix
    ./autostart.nix
    ./hypridle.nix
    ./hyprlock.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    configType = "lua";
    extraConfig = builtins.readFile ../../hypr/source/hyprland.lua;
  };

  xdg.configFile = {
    "hypr/lua".source = ../../hypr/source/lua;
    "hypr/mocha.conf".source = ../../hypr/mocha.conf;
    "hypr/nix-wallpaper-nineish-catppuccin-mocha-alt.png".source =
      ../../hypr/nix-wallpaper-nineish-catppuccin-mocha-alt.png;
    "hypr/scripts".source = ../../hypr/source/scripts;
  };
}
