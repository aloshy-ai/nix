{ config, pkgs, custom, ... }: {

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.${custom.username} = import ./home.nix { inherit config pkgs custom; };
  };
}