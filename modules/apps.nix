{ pkgs, ...}: {
  # Install packages from nix's official package repository.
  # These packages are available to all users, reproducible, and rollbackable.
  environment = {
    systemPackages = with pkgs; [
      git
      act
      deno
      nix-direnv
      flutter
      viu
      yadm
      localsend
      gh
      eza
      tree
      postman
      inetutils
      gnupg
      fh
      wget
      devenv
      devbox
      nixfmt
      mkpasswd
    ];

    variables = {
      SHELL = "zsh";
      EDITOR = "nano";
    };
  };
}
