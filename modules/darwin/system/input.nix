_: {
  system = {
    defaults = {
      NSGlobalDomain = {
        AppleSpacesSwitchOnActivate = false;
        AppleShowAllFiles = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        ApplePressAndHoldEnabled = false;
        "com.apple.trackpad.scaling" = 3.0;
        NSAutomaticWindowAnimationsEnabled = false;
        NSWindowShouldDragOnGesture = true;
        AppleICUForce24HourTime = true;
        _HIHideMenuBar = false;
      };

      trackpad = {
        FirstClickThreshold = 0;
        SecondClickThreshold = 0;
      };

      CustomUserPreferences = {
        "com.apple.AppleMultitouchTrackpad" = {
          TrackpadFourFingerVertSwipeGesture = 0;
          TrackpadThreeFingerVertSwipeGesture = 0;
        };

        "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
          TrackpadFourFingerVertSwipeGesture = 0;
          TrackpadThreeFingerVertSwipeGesture = 0;
        };

        "com.apple.HIToolbox" = {
          AppleFnUsageType = "Show Emoji & Symbols";
        };

        # Free ctrl-left/right for Zed by disabling Mission Control space-switching.
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            "80".enabled = false;
            "79".enabled = false;
          };
        };
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
      nonUS.remapTilde = true;
    };
  };
}
