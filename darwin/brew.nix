{ pkgs, lib, config, ci-detector, ... }: 
let
  isCI = ci-detector.lib.inCI;
in
{
  # Apps installed from Homebrew, exclusively on macOS.
  homebrew = {
    enable = true;

    # Install CLI apps from Homebrew (brew install)
    brews = [
      "nvm"
    ];

    # Install GUI apps from Homebrew Cask (brew install --cask)
    casks = [
      "cursor"
      "docker"
      "opera"
      "inkscape"
      "telegram"
      "webstorm"
      "claude"
      "chatgpt"
    ];

    # Install apps from the Mac App Store (Disabled on CI until `mas-cli` authentication is implemented).
    # The number is the app's ID from the App Store URL (e.g. https://apps.apple.com/ca/app/copyclip-clipboard-history/id595191960)
    masApps = lib.mkIf (!isCI) {
      copyclip = 595191960;
    };

    # Homebrew Configuration
    onActivation = {
      autoUpdate = true; # Automatically update packages when a new version is available.
      upgrade = true; # Upgrade all installed packages to the latest version.
      cleanup = "zap"; # Remove all installed packages that are not listed in the taps or brews.
    };

    # Install additional taps from Homebrew (brew tap)
    taps = [
      "homebrew/services" # For running services (e.g. `brew services run redis`)
    ];
  };

  # Configure Homebrew mirrors.
  environment = {
    variables = {
      HOMEBREW_API_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api";
      HOMEBREW_BOTTLE_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles";
      HOMEBREW_BREW_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git";
      HOMEBREW_CORE_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git";
      HOMEBREW_PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";
    };
  };

  # Set Homebrew environment variables before activation.
  system = {
    activationScripts = {
      preHomebrewActivation = {
        text = lib.mkBefore (lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "export ${name}=${value}") config.environment.variables));
      };
    };
  };
}
