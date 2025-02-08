{ pkgs, lib, hostname, custom, ci-detector, ... }: 
let
  isCI = ci-detector.lib.inCI;
in
{
  
  imports = [
    ./brew.nix
    ../shared
  ];

  users = {
    users = {
      "${custom.username}" = {
        name = custom.username;
        home = "/Users/${custom.username}";
        createHome = true;
        shell = pkgs.zsh;
        isHidden = false;
      };
    };
  };

  nix = {
    settings = {
      trusted-users = [ "@admin" custom.username ];
    };
  };

  security = {
    pam = {
      enableSudoTouchIdAuth = true;
    };
  };

  services = {
    nix-daemon = {
      enable = true;
    };
  };

  networking = {
    hostName = hostname;
    computerName = hostname;
  };

  system = {
    stateVersion = 5;
    activationScripts = {
      preUserActivation.text = ''
        LEGACY_USERNAME=$(whoami)
        if [ "${LEGACY_USERNAME}" != "${custom.username}" ]; then
          printf "SETTING UP SUDO PRIVILEGES FOR %s\n" "${custom.username}"
          printf "%s ALL=(ALL) NOPASSWD:ALL" "${custom.username}" | sudo tee /etc/sudoers.d/${custom.username}
          printf "RENAMING %s TO %s\n" "${LEGACY_USERNAME}" "${custom.username}"
          sudo dscl . -change /Users/${LEGACY_USERNAME} RecordName ${LEGACY_USERNAME} ${custom.username}
          printf "CHANGING HOME FOLDER\n"
          sudo dscl . -change /Users/${custom.username} NFSHomeDirectory /Users/${LEGACY_USERNAME} /Users/${custom.username}
        fi
      '';
      postUserActivation.text = ''
        ${pkgs.bash}/bin/bash -c '/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u'
      '';
    };

    defaults = lib.mkIf (!isCI) {
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
} 
