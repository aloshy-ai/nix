{ custom, ... }: {
  programs = {
    git = {
      enable = true;
      userName = custom.fullName;
      userEmail = custom.email;
      lfs = {
        enable = true;
      };
    };
  };
}
