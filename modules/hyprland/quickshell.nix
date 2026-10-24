{ pkgs, ... }:

{
  programs.quickshell = {
    enable = true;
    activeConfig = "desktop";
    configs.desktop = ../../quickshell;
    systemd.enable = true;
    systemd.target = "hyprland-session.target";
  };

  systemd.user.services.quickshell.Unit.PartOf = [ "hyprland-session.target" ];
  home.packages = [ pkgs.pavucontrol pkgs.pulseaudio ];
}
