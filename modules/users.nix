{ userConfig, ... }: {
  users = {
    users = {
      ${userConfig.username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh = {
          authorizedKeys = {
            keys = [
              userConfig.publicKey
            ];
          };
        };
        hashedPassword = userConfig.hashedPassword;
      };
      runner = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
    };
  };
}