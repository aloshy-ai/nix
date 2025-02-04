{ pkgs, ... }: {
  # Nixpkgs configuration
  nixpkgs.config = {
    allowUnfree = true;
  };

  # Nix package manager configuration
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

    nrBuildUsers = 32;
  };
}
