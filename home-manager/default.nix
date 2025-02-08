{ pkgs, lib, custom, ... }: {

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.${custom.username} = import ./home.nix { inherit pkgs lib custom; };
  };
}