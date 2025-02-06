{ config, lib, pkgs, userConfig, ... }: {
  imports = [];

  home = {
    packages = with pkgs; [
      devbox
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
    ];
    stateVersion = pkgs.lib.trivial.release;
    shellAliases = {};
    sessionPath = [];
    activation = {
      linkDevboxConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        DEVBOX_GLOBAL_DIR="$(${pkgs.devbox}/bin/devbox -q global path)"
        $DRY_RUN_CMD mkdir -p "$DEVBOX_GLOBAL_DIR"
        [ -f "$DEVBOX_GLOBAL_DIR/devbox.json" ] && $DRY_RUN_CMD rm "$DEVBOX_GLOBAL_DIR/devbox.json"
        $DRY_RUN_CMD ln -sf $VERBOSE_ARG \
          "${config.home-manager.users.${userConfig.username}.home.homeDirectory}/.config/nix-darwin/devbox.json" \
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
        eval "$(devbox global shellenv --preserve-path-stack -r)" && hash -r
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
    starship = {
      enable = true;
      enableZshIntegration = true;
    };
    vscode = {
      enable = true;
      package = pkgs.vscode;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        github.vscode-github-actions
        github.copilot
        github.copilot-chat
        github.codespaces
        github.github-vscode-theme
        github.vscode-pull-request-github
        esbenp.prettier-vscode
      ];
      userSettings = {
        "window.zoomLevel" = 1;
        "editor.fontSize" = 13;
        "editor.tabSize" = 4;
        "editor.fontFamily" = "'JetBrainsMono Nerd Font'";
        "editor.folding" = true;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.lineHeight" = 22;
        "editor.fontWeight" = "500";
        "editor.semanticHighlighting.enabled" = true;
        "editor.formatOnSave" = true;
        "files.autoSave" = "afterDelay";
        "cursor.aipreview.enabled" = true;
        "cursor.cmdk.useThemedDiffBackground" = true;
        "cursor.cpp.enablePartialAccepts" = true;
        "terminal.integrated.fontSize" = 14;
        "RainbowBrackets.depreciation-notice" = false;
        "RainbowBrackets.colorMode" = "Consecutive";
        "breadcrumbs.enabled" = false;
        "workbench.tree.enableStickyScroll" = false;
        "workbench.tree.indent" = 14;
        "workbench.tree.renderIndentGuides" = "always";
        "workbench.sideBar.location" = "left";
        "workbench.colorCustomizations" = {
          "activityBar.background" = "#282c34";
          "sideBar.background" = "#282c34";
          "tab.activeBackground" = "#282c34";
          "editor.background" = "#1e1e1e";
          "editor.foreground" = "#d4d4d4";
          "editorIndentGuide.background1" = "#404040";
          "editorRuler.foreground" = "#333333";
          "activityBarBadge.background" = "#007acc";
          "sideBarTitle.foreground" = "#bbbbbb";
        };
      };
    };
  };
}
