{ userConfig, ... }: {
  imports = [
    ./direnv.nix
    ./gh.nix
    (import ./git.nix { inherit userConfig; })
    ./starship.nix
    ./vscode.nix
    ./zsh.nix
  ];
}
