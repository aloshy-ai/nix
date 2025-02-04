{ pkgs, userConfig, lib, config, ... }: {
  imports = [];

  home = {
    packages = with pkgs; [
      devbox
    ];
    stateVersion = pkgs.lib.trivial.release;
    shellAliases = {};
    sessionPath = [];
    activation = {
      linkDevboxConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        DEVBOX_GLOBAL_DIR="$(${pkgs.devbox}/bin/devbox global path)"
        $DRY_RUN_CMD mkdir -p "$DEVBOX_GLOBAL_DIR"
        [ -f "$DEVBOX_GLOBAL_DIR/devbox.json" ] && $DRY_RUN_CMD rm "$DEVBOX_GLOBAL_DIR/devbox.json"
        $DRY_RUN_CMD ln -sf $VERBOSE_ARG \
          "${config.home.homeDirectory}/.config/nix-darwin/devbox.json" \
          "$DEVBOX_GLOBAL_DIR/devbox.json"
      '';
    };
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
      enableZshIntegration = true;
    };
  };
}
