{ pkgs, lib, config, custom, ... }: {

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.${custom.username} = import ./home.nix;
  };
}