{ pkgs, userConfig, ... }:{

  imports = [
  ];

  home-manager = {
    users = {
      ${userConfig.username} = { pkgs, ... }: {
        home = {
          packages = with pkgs; [ devbox ];
          stateVersion = "25.05";
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
      };
    };
  };
}