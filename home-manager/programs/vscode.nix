{ pkgs, ... }: {
  programs = {
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
