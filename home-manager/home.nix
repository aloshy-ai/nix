{ pkgs, userConfig, ... }: {
  imports = [ ];

  home = {
    packages = with pkgs; [ devbox ];
    stateVersion = pkgs.lib.trivial.release;
    shellAliases = {};
    sessionPath = [];
    activation = {};
    sessionVariables = {
      DIRENV_LOG_FORMAT = "";
    };
  };

  programs = {
    bash = {
      enable = true;
    };
    zsh = {
      enable = true;
      initExtra = ''
        eval "$(devbox global shellenv --init-hook)"
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
