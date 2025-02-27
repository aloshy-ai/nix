{ pkgs, custom, ... }: {

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${custom.username} = import ../home-manager/home.nix { 
      inherit pkgs custom; 
    };
  };

  # System level Environment variables on all systems.
  environment = {
    variables = {
      SHELL = "zsh";
      EDITOR = "nano";
    };
  };

  # Nixpkgs configuration for all systems.
  nixpkgs.config = {
    allowUnfree = true;
  };

  # Nix package manager configuration for all systems.
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = false;
      cores = 0; # Use all cores
      max-jobs = "auto"; # Use all logical cores
      min-free = toString (1024 * 1024 * 1024); # 1 GiB
      max-free = toString (10 * 1024 * 1024 * 1024); # 10 GiB
      
      substituters = [
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      builders-use-substitutes = true;
    };

    gc = {
      automatic = pkgs.lib.mkDefault true;
      options = pkgs.lib.mkDefault "--delete-older-than 1d";
    };

    extraOptions = ''
      accept-flake-config = true
    '';

    nrBuildUsers = 32;
  };
}
