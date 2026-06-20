# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.

  programs.hyprland.enable = true;

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
   i18n.defaultLocale = "de_DE.UTF-8";
   console = {
     # font = "Lat2-Terminus16";
     keyMap = "de";
   };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  services.xserver.xkb.layout = "de";
  services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
   services.pipewire = {
     enable = true;
     pulse.enable = true;
   };
systemd.user.services.mako = {
    description = "Mako notification daemon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.mako}/bin/mako";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.zoltan = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
       tree
     ];
   };

  nixpkgs.config.allowUnfree = true;
  
  programs._1password.enable = true;
  programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = ["zoltan"];
    };

  # programs.firefox.enable = true;
   programs.thunar = {
     enable = true;
     plugins = with pkgs; [
       thunar-archive-plugin
       thunar-volman
     ];
   };
   
   services.udisks2.enable = true;
   services.gvfs.enable = true;
   services.tumbler.enable = true;

   environment.variables = {
     EDITOR = "nvim";
     VISUAL = "nvim";
     TERMINAL = "kitty";
   };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
   environment.systemPackages = with pkgs; [
     neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     fastfetch
     gnumake
     gcc
     ripgrep
     tree-sitter
     fd
     # LSPs und Formatter 
     lua-language-server
     stylua
     nil
     btop
     iwd
     mako
     libnotify
     awww
     fzf
     wget
     hypridle
     hyprlock
     hyprpolkitagent
     slurp
     grim
     jq
     swappy
     wl-clipboard
     git
     yazi
     brave
     kitty
     rofi
     waybar
     zoxide
     wiremix
     impala
     bluetui
     nwg-look
     tldr
     arc-theme
     (catppuccin-gtk.override {
      accents = [ "mauve" ]; # Wähle deine Akzentfarbe (z.B. mauve, blue, pink, etc.)
      variant = "mocha";     # Wähle deine Variante (latte, frappe, macchiato, mocha)
      tweaks = [ "rimless" ]; # Optional: Anpassungen wie "rimless" oder "black"
    })
    
    # Optional aber empfohlen: Ein passendes Icon-Theme (z.B. Papirus im Catppuccin-Look)
    (catppuccin-papirus-folders.override {
      flavor = "mocha";
      accent = "mauve";
    })
    
    # gsettings Tool (wichtig, damit Hyprland das Theme an GTK3/4 Apps übergeben kann)
    glib.bin
    gnome-settings-daemon
   ];
 # 2. GTK-Settings systemweit erzwingen
  # Das sorgt dafür, dass dconf und gsettings-Pfade für alle User bereitstehen
  programs.dconf.enable = true;

  # Standard-Themes für GTK2 und GTK3 festlegen
  environment.etc."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name = catppuccin-mocha-mauve-standard+rimless
    gtk-icon-theme-name = Catppuccin-Mocha-Mauve
    gtk-application-prefer-dark-theme = 1
  '';

  environment.etc."gtk-2.0/gtkrc".text = ''
    gtk-theme-name = "catppuccin-mocha-mauve-standard+rimless"
    gtk-icon-theme-name = "Catppuccin-Mocha-Mauve"
  ''; 
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  environment.variables = {
    GTK_THEME = "Arc-Dark";
    XCURSOR_THEME = "Adwaita";
    XFCE_TERM = "kitty";
  };


  fonts.fontDir.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.iosevka
    nerd-fonts.caskaydia-mono
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    noto-fonts-monochrome-emoji
    noto-fonts-emoji-blob-bin
  ];
  


  console = {
    enable = true;
    earlySetup = true; 
    font = "ter-powerline-v24b"; # Scharfe Bitmap-Schrift, ideal für 1080p/1440p
    packages = with pkgs; [
      terminus_font
      powerline-fonts
    ];
  };
  services.getty.greetingLine = ''
\e[1;32m
NNNNNNNN        NNNNNNNN  iiii                           OOOOOOOOO        SSSSSSSSSSSSSSS 
N:::::::N       N::::::N i::::i                        OO:::::::::OO    SS:::::::::::::::S
N::::::::N      N::::::N  iiii                       OO:::::::::::::OO S:::::SSSSSS::::::S
N:::::::::N     N::::::N                            O:::::::OOO:::::::OS:::::S     SSSSSSS
N::::::::::N    N::::::Niiiiiii xxxxxxx      xxxxxxxO::::::O   O::::::OS:::::S            
N:::::::::::N   N::::::Ni:::::i  x:::::x    x:::::x O:::::O     O:::::OS:::::S            
N:::::::N::::N  N::::::N i::::i   x:::::x  x:::::x  O:::::O     O:::::O S::::SSSS         
N::::::N N::::N N::::::N i::::i    x:::::xx:::::x   O:::::O     O:::::O  SS::::::SSSSS    
N::::::N  N::::N:::::::N i::::i     x::::::::::x    O:::::O     O:::::O    SSS::::::::SS  
N::::::N   N:::::::::::N i::::i      x::::::::x     O:::::O     O:::::O       SSSSSS::::S 
N::::::N    N::::::::::N i::::i      x::::::::x     O:::::O     O:::::O            S:::::S
N::::::N     N:::::::::N i::::i     x::::::::::x    O::::::O   O::::::O            S:::::S
N::::::N      N::::::::Ni::::::i   x:::::xx:::::x   O:::::::OOO:::::::OSSSSSSS     S:::::S
N::::::N       N:::::::Ni::::::i  x:::::x  x:::::x   OO:::::::::::::OO S::::::SSSSSS:::::S
N::::::N        N::::::Ni::::::i x:::::x    x:::::x    OO:::::::::OO   S:::::::::::::::SS 
NNNNNNNN         NNNNNNNiiiiiiiixxxxxxx      xxxxxxx     OOOOOOOOO      SSSSSSSSSSSSSSS   
\e[0m
Welcome to \e[1;34mNixOS\e[0m (\n) - Running on \l
  '';

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}

