{ pkgs, ...}: {
  # Install packages from nix's official package repository.
  # These packages are available to all users, reproducible, and rollbackable.
  environment = {
    systemPackages = with pkgs; [
    ];

    variables = {
      SHELL = "zsh";
      EDITOR = "nano";
    };
  };
}
