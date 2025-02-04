{ lib, ... }: {
  homebrew = {
    masApps = lib.mkIf (!builtins.getEnv "CI" == "true") {
      copyclip = 595191960;
    };
  };
}
