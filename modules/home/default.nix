{ pkgs, ... }:

{
  home-manager = {
    backupFileExtension = "hm-backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    
    users.zoltan = { ... }: {
      home.stateVersion = "26.05";

      imports = [
        ./packages.nix
        ../hyprland/default.nix
      ];
    };
  };
}
