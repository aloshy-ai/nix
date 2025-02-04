{ pkgs, hostname, userConfig, ... }: {
  
  imports = [
    ./brew-apps.nix
    ./store-apps.nix
    ../modules
  ];

  users = {
    users = {
      "${userConfig.username}" = {
        name = userConfig.username
        home = "/Users/${userConfig.username}";
      };
    };
  };

  home-manager = {
    users = {
      "${userConfig.username}" = { pkgs, ... }: {
        home.stateVersion = pkgs.lib.trivial.release;
      };
    };
  };

  nix = {
    settings = {
      trusted-users = [ "@admin" userConfig.username ];
    };
  };

  system = {
    stateVersion = 5;
    
    # Reload settings without requiring logout
    activationScripts = {
      postUserActivation.text = ''
        ${pkgs.bash}/bin/bash -c '
          # Activate settings
          /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
        '
      '';
    };

    defaults = {
      menuExtraClock.Show24Hour = true;

      dock = {
        autohide = true;
        show-recents = false;
        tilesize = 24;
        orientation = "right";
      };

      finder = {
        _FXShowPosixPathInTitle = true;
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };

      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = true;
        "com.apple.sound.beep.feedback" = 0;
        AppleInterfaceStyle = "Dark";
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 3;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
      };

      CustomUserPreferences = {
        ".GlobalPreferences".AppleSpacesSwitchOnActivate = true;

        "com.apple.finder" = {
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = true;
          ShowMountedServersOnDesktop = true;
          ShowRemovableMediaOnDesktop = true;
          _FXSortFoldersFirst = true;
          FXDefaultSearchScope = "SCcf";
        };

        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };

        "com.apple.screencapture" = {
          location = "~/Desktop";
          type = "png";
        };

        "com.apple.spaces".spans-displays = 0;

        "com.apple.WindowManager" = {
          EnableStandardClickToShowDesktop = 0;
          StandardHideDesktopIcons = 0;
          HideDesktop = 0;
        };

        "com.apple.screensaver" = {
          askForPassword = 1;
          askForPasswordDelay = 0;
        };

        "com.apple.AdLib".allowApplePersonalizedAdvertising = false;
        "com.apple.ImageCapture".disableHotPlug = true;
      };

      loginwindow = {
        GuestEnabled = false;
        SHOWFULLNAME = true;
      };

      smb.NetBIOSName = hostname;
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = false;
    };
  };

  # System configuration
  security.pam.enableSudoTouchIdAuth = true;
  services.nix-daemon.enable = true;

  # Networking configuration
  networking = {
    hostName = hostname;
    computerName = hostname;
  };
} 
