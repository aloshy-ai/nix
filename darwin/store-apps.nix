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

  # Add this temporarily for debugging
  system.activationScripts.debug-ci = {
    text = ''
      echo "CI Detection Debug:"
      echo "GITHUB_ACTIONS=${builtins.getEnv "GITHUB_ACTIONS"}"
      echo "Is CI according to detector: ${toString isCI}"
    '';
  };
}
