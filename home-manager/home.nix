{ pkgs, lib, userConfig, ... }: {
  imports = [ ];

  home = {
    packages = with pkgs; [ devbox ];
    stateVersion = lib.trivial.release;
  };

  programs = {
    bash = {
      enable = true;
    };
    zsh = {
      enable = true;
      initExtra = ''
        eval "$(devbox global shellenv)"
      '';
    };
    git = {
      enable = true;
      userName = userConfig.fullName;
      userEmail = userConfig.email;
      lfs = {
        enable = true;
      };
    };
    gh = {
      enable = true;
    };
    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
      enableBashIntegration = true;
    };
  };
}