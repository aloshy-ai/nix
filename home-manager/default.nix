{ config, pkgs, custom, ... }: {

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.${custom.username} = { config, pkgs, lib, custom, ... }: {
      
    };
  };
}