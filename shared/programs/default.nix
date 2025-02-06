{ custom, ... }: {
  imports = [
    ./direnv.nix
    ./gh.nix
    (import ./git.nix { inherit custom; })
    ./starship.nix
    ./vscode.nix
    ./zsh.nix
  ];
}
