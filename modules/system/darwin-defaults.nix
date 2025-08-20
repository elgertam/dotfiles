{ ... }:

{
  config = {
    system.defaults.dock = {
      autohide = true;
      wvous-tr-corner = 2;
      wvous-br-corner = 3;
      magnification = true;
    };

    system.defaults.finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      FXPreferredViewStyle = "clmv";
      QuitMenuItem = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
    };

    system.defaults.menuExtraClock = {
      Show24Hour = true;
      ShowAMPM = false;
      ShowDate = 1;
      ShowDayOfWeek = true;
      ShowDayOfMonth = true;
      ShowSeconds = true;
    };

    system.defaults.NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 35;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      "com.apple.swipescrolldirection" = false;
      "com.apple.mouse.tapBehavior" = 1;
    };

    system.defaults.screencapture = {
      target = "clipboard";
      type = "png";
    };

    system.defaults.trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
    };

    # Ensure Universal Clipboard (Handoff clipboard) is enabled
    system.defaults.CustomUserPreferences = {
      "com.apple.coreservices.useractivityd" = {
        ClipboardSharingEnabled = 1;
      };
    };

    # Security settings
    security.pam.services.sudo_local.touchIdAuth = true;
    security.pam.services.sudo_local.reattach = true;
  };
}
