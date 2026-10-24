{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fastfetch
    bat
    bat-extras.batman
    ripgrep
    fd
    tree-sitter
    lua-language-server
    stylua
    nil
    btop
    yazi
    lazygit
    brave
    awww
    fzf
    zoxide
    wiremix
    impala
    bluetui
    nwg-look
    tldr
    mpv
    imv
    peazip
    arc-theme
    (catppuccin-gtk.override {
      accents = [ "mauve" ];
      variant = "mocha";
      tweaks = [ "rimless" ];
    })
    (catppuccin-papirus-folders.override {
      flavor = "mocha";
      accent = "mauve";
    })
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "kitty";
    GTK_THEME = "Arc-Dark";
    XCURSOR_THEME = "Adwaita";
  };
}
