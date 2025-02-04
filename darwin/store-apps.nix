{ lib, ... }: {
  homebrew = {
    masApps = lib.mkIf (builtins.getEnv "GITHUB_ACTIONS" != "true") {
      copyclip = 595191960;
    };
  };
}
