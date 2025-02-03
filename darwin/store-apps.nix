{ pkgs, ... }: {
  homebrew = {
    masApps = lib.mkIf (!builtins.getEnv "CI") {
      copyclip = 595191960;
    };
  };
}

