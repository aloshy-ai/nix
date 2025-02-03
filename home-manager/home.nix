{ pkgs, lib, userConfig, ... }: {
  imports = [ ];

  home = {
    packages = with pkgs; [ devbox ];
    stateVersion = pkgs.lib.trivial.release;
    activation = {
      # Remove existing gitconfig to avoid conflicts
      removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''rm -f ~/.gitconfig'';
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
        eval "$(direnv hook zsh)"
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
