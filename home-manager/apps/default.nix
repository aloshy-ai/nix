{ config, lib, pkgs, userConfig, ... }: {
  imports = [
    ./direnv.nix
    ./gh.nix
    ./git.nix { inherit userConfig; }
    ./starship.nix
    ./vscode.nix
    ./zsh.nix
  ];
}
