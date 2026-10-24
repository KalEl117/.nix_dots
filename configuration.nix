{ config, lib, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> { };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/home/default.nix
      <home-manager/nixos>
    ];

  security.pam.services.hyprlock = {};
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.limine = {
  enable = true;
  resolution = "2560x1440";
  maxGenerations = 8;
  style = {
    interface = {
      resolution = "2560x1440";
      branding = "NixOS";
      helpHidden = true; 
    };

    graphicalTerminal = {
      font.scale = "1x1";
      margin = 0; 
    };
  };
  extraConfig = ''
    term_width: 1000
    term_height: 500
    term_margin_left: 780
    term_margin_right: 780
    term_margin_top: 470
    term_margin_bottom: 470
  '';
};
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Vienna";

   i18n.defaultLocale = "de_DE.UTF-8";
   console = {
     # font = "Lat2-Terminus16";
     keyMap = "de";
   };

  # services.xserver.enable = true;
  services.udev.extraRules = ''
    #Wecken für alle USB-Eingabegeräte (Tastatur, Mäuse, Trackballs) aktivieren
    ACTION=="add", SUBSYSTEM=="usb", ATTR{power/wakeup}="enable"
  '';

  

  services.xserver.xkb.layout = "de";
  services.xserver.xkb.options = "eurosign:e,caps:escape";

  services.printing.enable = true;

  # services.pulseaudio.enable = true;
  # OR
   services.pipewire = {
     enable = true;
     pulse.enable = true;
   };
  services.libinput.enable = true;

   users.users.zoltan = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
   };

  nixpkgs.config.allowUnfree = true;
  
  programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  programs._1password.enable = true;
  programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = ["zoltan"];
    };

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
   programs.dconf.enable = true;

  environment.pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];
   environment.systemPackages = with pkgs; [
     neovim
     git
     gcc
     gnumake
     wget
     kitty
     unstable.codex
     unstable.opencode
     unstable.herdr
   ];

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
    font = "ter-powerline-v24b"; 
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
  system.stateVersion = "26.05";
}
