{ config, lib, pkgs, custom, ci-detector, homebrew-core, homebrew-cask, homebrew-bundle, ... }:
let
  isCI = ci-detector.lib.inCI;
in
{
  # Regular Homebrew configuration
  homebrew = {
    enable = true;
    
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    # Example packages - adjust these to your needs
    brews = [
      "nvm"
    ];

    casks = [
      "docker"
    ];

    taps = [
      "homebrew/services"
    ];

    # Mac App Store apps (disabled in CI)
    masApps = lib.mkIf (!isCI) {
      # Example: 
      # copyclip = 595191960;
    };
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = custom.username;
    autoMigrate = true;
  };

  # Optional: Configure Homebrew mirrors if needed
  environment.variables = {
    HOMEBREW_API_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api";
    HOMEBREW_BOTTLE_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles";
    HOMEBREW_BREW_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git";
    HOMEBREW_CORE_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git";
    HOMEBREW_PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";
  };
}
