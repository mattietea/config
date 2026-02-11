_:

{
  ########################################################################
  # Input: Keyboard, Trackpad, Global Input Settings
  ########################################################################

  system = {
    defaults = {
      ########################################################################
      # Global UI / Input (NSGlobalDomain)
      ########################################################################

      NSGlobalDomain = {
        # Disable "Switch to Space with open windows" when activating apps
        # Prevents macOS from jumping to the Space that contains an app's window.
        AppleSpacesSwitchOnActivate = false;
        # Show hidden files globally in open/save panels (redundant with Finder domain, kept for convenience)
        AppleShowAllFiles = true;
        # Keyboard repeat timing
        # Lower is faster. InitialKeyRepeat is delay before repeating starts.
        InitialKeyRepeat = 15; # common values: 120, 94, 68, 35, 25, 15
        KeyRepeat = 2; # common values: 120, 90, 60, 30, 12, 6, 2
        # Disable Press-and-Hold accent menu (enables key repeating)
        ApplePressAndHoldEnabled = false;
        # Trackpad cursor tracking speed (0.0 to 3.0)
        "com.apple.trackpad.scaling" = 3.0;
        # Disable window/panel animations for snappier feel
        NSAutomaticWindowAnimationsEnabled = false;
        # Allow dragging a window by holding a modifier gesture (three-finger drag-like behavior)
        NSWindowShouldDragOnGesture = true;
        # Force 24-hour time (independent from region defaults)
        AppleICUForce24HourTime = true;
        # Menu bar visibility for full-screen apps (legacy; on newer macOS, see per-app behavior)
        _HIHideMenuBar = false;
      };

      # Common NSGlobalDomain options (commented):
      # Enable swipe to navigate (two-finger swipe back/forward)
      # defaults.NSGlobalDomain.AppleEnableSwipeNavigateWithScrolls = true;
      # defaults.NSGlobalDomain.AppleEnableMouseSwipeNavigateWithScrolls = true;
      #
      # Spelling/Quotes/Dashes/Period substitutions
      # defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
      # defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
      # defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
      # defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
      #
      # Scroll animation
      # defaults.NSGlobalDomain.NSScrollAnimationEnabled = true;
      #
      # Focus ring animation
      # defaults.NSGlobalDomain.NSUseAnimatedFocusRing = true;
      #
      # Show control characters (caret notation) in text views
      # defaults.NSGlobalDomain.NSTextShowsControlCharacters = false;
      #
      # When to show scroll bars: "Automatic" | "WhenScrolling" | "Always"
      # defaults.NSGlobalDomain.AppleShowScrollBars = "WhenScrolling";
      #
      # Use metric units (1 = metric, 0 = imperial)
      # defaults.NSGlobalDomain.AppleMetricUnits = 1;
      #
      # Temperature unit: "Celsius" | "Fahrenheit"
      # defaults.NSGlobalDomain.AppleTemperatureUnit = "Celsius";
      #
      # Expanded save/print panels by default
      # defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
      # defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
      # defaults.NSGlobalDomain.PMPrintingExpandedStateForPrint = true;
      # defaults.NSGlobalDomain.PMPrintingExpandedStateForPrint2 = true;
      #
      # Save new documents to iCloud by default (true) or local disk (false)
      # defaults.NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
      #
      # Keyboard UI mode (2 = enabled on Sonoma+, 3 = enabled on older)
      # defaults.NSGlobalDomain.AppleKeyboardUIMode = 2;

      ########################################################################
      # Menu Bar Clock
      ########################################################################

      # Common clock options (commented):
      # Show seconds in the menu bar clock
      # defaults.menuExtraClock.ShowSeconds = true;
      #
      # Show 24-hour time in the menu bar clock
      # defaults.menuExtraClock.Show24Hour = true;
      #
      # Show day of week
      # defaults.menuExtraClock.ShowDayOfWeek = true;
      #
      # Show day of month
      # defaults.menuExtraClock.ShowDayOfMonth = true;
      #
      # Flash time separators (e.g., blinking colon)
      # defaults.menuExtraClock.FlashDateSeparators = false;
      #
      # Show full date: 0 = When space allows, 1 = Always, 2 = Never
      # defaults.menuExtraClock.ShowDate = 0;

      ########################################################################
      # Trackpad (Pressure/Click thresholds and gestures)
      ########################################################################

      trackpad = {
        # Click weight (0 = light, 1 = medium (default), 2 = firm)
        FirstClickThreshold = 0;
        # Force Click pressure (0 = light, 1 = medium (default), 2 = firm)
        SecondClickThreshold = 0;
      };

      # Per-user trackpad gesture overrides (custom user domains) are added
      # under defaults.CustomUserPreferences below.

      # Common trackpad options (commented):
      # Tap to click (system-wide tap behavior: 1=enable for this user)
      # defaults.NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
      #
      # Enable tap-to-click (trackpad domain)
      # defaults.trackpad.Clicking = true;
      #
      # Enable right-click via trackpad
      # defaults.trackpad.TrackpadRightClick = true;
      #
      # Enable tap-to-drag
      # defaults.trackpad.Dragging = true;
      #
      # Three-finger drag (accessibility style drag)
      # defaults.trackpad.TrackpadThreeFingerDrag = true;
      #
      # Three-finger tap gesture: 0 = off, 2 = Look up & data detectors
      # defaults.trackpad.TrackpadThreeFingerTapGesture = 0;
      #
      # Silent clicking (0 = silent, 1 = default)
      # defaults.trackpad.ActuationStrength = 0;

      ########################################################################
      # Custom User Preferences (Per-user domains and keys)
      ########################################################################

      # These are per-user preferences for the current user, useful for trackpad
      # gesture toggles that are stored in user-specific domains.
      CustomUserPreferences = {
        # Safari developer/debug menus (moved from system to per-user)
        # "com.apple.Safari" = {
        #   WebKitDeveloperExtrasEnabledPreferenceKey = true;
        #   IncludeInternalDebugMenu = true;
        #   IncludeDevelopMenu = true;
        # };

        # Built-in trackpad domain
        "com.apple.AppleMultitouchTrackpad" = {
          # Disable four-finger vertical swipe (commonly Mission Control)
          TrackpadFourFingerVertSwipeGesture = 0;

          # Disable three-finger vertical swipe (Mission Control on some models/OS)
          TrackpadThreeFingerVertSwipeGesture = 0;
        };

        # Bluetooth trackpad domain (e.g., Magic Trackpad)
        "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
          # Disable four-finger vertical swipe
          TrackpadFourFingerVertSwipeGesture = 0;

          # Disable three-finger vertical swipe
          TrackpadThreeFingerVertSwipeGesture = 0;
        };

        # Fn/Globe key action (per-user HIToolbox domain)
        "com.apple.HIToolbox" = {
          AppleFnUsageType = "Show Emoji & Symbols";
        };

        # Disable Mission Control space-switching shortcuts (ctrl-left/right)
        # to allow apps like Zed to use these keybindings
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            # Disable "Move left a space" (ctrl-left)
            "80" = {
              enabled = false;
            };
            # Disable "Move right a space" (ctrl-right)
            "79" = {
              enabled = false;
            };
          };
        };
      };
    };

    ########################################################################
    # Keyboard mappings / modifiers
    ########################################################################

    keyboard = {
      # Enable keyboard mappings (required for below remaps)
      enableKeyMapping = true;

      # Remap Caps Lock to Escape
      remapCapsLockToEscape = true;

      # On non-US keyboards, remap the key to produce the tilde (~) more easily
      nonUS.remapTilde = true;
    };

    ########################################################################
    # Fn / Globe key action
    ########################################################################

    # Configure the Fn/Globe key action (requires restart to fully apply on some versions)
    # Options include: "Do Nothing", "Change Input Source", "Show Emoji & Symbols", "Start Dictation"
    # Fn/Globe key action is now configured under defaults.CustomUserPreferences."com.apple.HIToolbox" below
  };
}
