{ ... }: {
  programs = {
    zsh = {
      enable = true;
      initExtra = ''
        eval "$(devbox global shellenv --preserve-path-stack -r)" && hash -r
      '';
    };
  };
}
