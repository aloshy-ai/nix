{ pkgs, custom, ... }: {

  imports = [
    ./programs
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    
    users.${custom.username} = { config, lib, ... }: {
      # Basic home configuration
      home = {
        username = custom.username;
        homeDirectory = if pkgs.stdenv.isDarwin 
          then "/Users/${custom.username}"
          else "/home/${custom.username}";
        packages = with pkgs; [
          devbox
          nerd-fonts.fira-code
          nerd-fonts.jetbrains-mono
          nerd-fonts.symbols-only
        ];
        stateVersion = pkgs.lib.trivial.release;
        shellAliases = {};
        sessionPath = [];
      };

      # Add activation script for devbox configuration
      home.activation = {
        linkDevboxConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
          DEVBOX_GLOBAL_DIR="$(${pkgs.devbox}/bin/devbox -q global path)"
          $DRY_RUN_CMD mkdir -p "$DEVBOX_GLOBAL_DIR"
          [ -f "$DEVBOX_GLOBAL_DIR/devbox.json" ] && $DRY_RUN_CMD rm "$DEVBOX_GLOBAL_DIR/devbox.json"
          $DRY_RUN_CMD ln -sf $VERBOSE_ARG \
            "${config.home.homeDirectory}/.config/nix-darwin/devbox.json" \
            "$DEVBOX_GLOBAL_DIR/devbox.json"
        '';
      };

      # Session variables  
      home.sessionVariables = {
        DIRENV_LOG_FORMAT = "";
      };

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # Enable home-manager to manage itself
      programs.home-manager.enable = true;
    };
  };
}