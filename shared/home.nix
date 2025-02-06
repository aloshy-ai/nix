{ config, lib, pkgs, custom, ... }: {
  imports = [
    ./programs
  ];

  home = {
    packages = with pkgs; [
      devbox
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
    ];
    username = custom.username;
    homeDirectory = "/Users/${custom.username}";
    stateVersion = pkgs.lib.trivial.release;
    shellAliases = {};
    sessionPath = [];
    activation = {
      linkDevboxConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        DEVBOX_GLOBAL_DIR="$(${pkgs.devbox}/bin/devbox -q global path)"
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
}
