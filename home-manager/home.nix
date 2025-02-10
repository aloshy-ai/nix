{ pkgs, custom, ... }: {
  home = {
    username = custom.username;
    homeDirectory = if pkgs.stdenv.isDarwin
      then "/Users/${custom.username}"
      else "/home/${custom.username}";
    
    packages = with pkgs; [
      # Add your common packages here
    ];

        stateVersion = pkgs.lib.trivial.release;
  };

  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      userName = custom.fullName;
      userEmail = custom.email;
    };
    # Add other program configurations
  };
}