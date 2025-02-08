{ config, lib, pkgs, custom, ci-detector, ... }:
let
  isCI = ci-detector.lib.inCI;
in
{
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = custom.username;
    
    # Optional: Declarative tap management
    mutableTaps = true; # Set to false if you want fully declarative tap management
    
    # Your taps will be automatically managed since you've set them up in flake inputs
    taps = {
      "homebrew/homebrew-core" = config.homebrew-core;
      "homebrew/homebrew-cask" = config.homebrew-cask;
      "homebrew/homebrew-bundle" = config.homebrew-bundle;
    };
  };

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

  # Optional: Configure Homebrew mirrors if needed
  environment.variables = {
    HOMEBREW_API_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api";
    HOMEBREW_BOTTLE_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles";
    HOMEBREW_BREW_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git";
    HOMEBREW_CORE_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git";
    HOMEBREW_PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";
  };
}
