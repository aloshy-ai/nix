{ pkgs, ... }: {
  # Homebrew must be installed manually: https://brew.sh
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap"; # Uninstalls all formulae not listed here
    };

    taps = [
      "homebrew/services"
    ];

    brews = [
      "fish"
      "wget"
      "curl"
      "aria2"
      "httpie"
      "nvm"
    ];

    casks = [
      "chromium"
      "framer"
      "cursor"
      "chatgpt"
      "claude"
      "webstorm"
      "visual-studio-code"
      "discord"
      "iina"
      "raycast"
      "stats"
      "insomnia"
      "wireshark"
      "microsoft-edge"
      "slack"
      "desktoppr"
      "github"
      "gimp"
      "inkscape"
    ];
  };
}
