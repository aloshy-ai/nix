{ lib, ci-detector, ... }: {
  homebrew = {
    masApps = lib.mkIf (!ci-detector.lib.inCI) {
      copyclip = 595191960;
    };
  };
}
