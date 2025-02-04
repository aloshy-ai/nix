{ lib, ci-detector, ... }: {
  homebrew = {
    masApps = lib.mkIf (ci-detector.lib.notInCI) {
      copyclip = 595191960;
    };
  };
}
