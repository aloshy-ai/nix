{ lib, ci-detector, ... }: 
let
  isCI = ci-detector.lib.inCI;
in
{
  homebrew = {
    masApps = lib.mkIf (!isCI) {
      copyclip = 595191960;
    };
  };
}
