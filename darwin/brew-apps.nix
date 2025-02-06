{ pkgs, lib, config, ... }: {
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    taps = [
      "homebrew/services"
    ];

    brews = [
      "nvm"
    ];

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
  };

  environment.variables = {
    HOMEBREW_API_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api";
    HOMEBREW_BOTTLE_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles";
    HOMEBREW_BREW_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git";
    HOMEBREW_CORE_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git";
    HOMEBREW_PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";
  };

  system.activationScripts.preHomebrewActivation.text = lib.mkBefore (lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "export ${name}=${value}") config.environment.variables));
}
