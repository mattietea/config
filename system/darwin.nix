{ settings, ... }:

{
  ##########################################################################
  # nix-darwin: macOS system configuration
  #
  # This file groups and documents macOS defaults and related settings.
  # - All existing settings are kept.
  # - Additional commonly-used defaults are provided but commented out.
  # - Settings are grouped by area for easier maintenance.
  #
  ##########################################################################

  ##########################################################################
  # Authentication / Security
  ##########################################################################

  # Enable Touch ID for sudo authentication (where supported)
  security.pam.services.sudo_local.touchIdAuth = true;

  ##########################################################################
  # Core System Meta
  ##########################################################################
  system = {
    # Used by nix-darwin for backwards compatibility of module options.
    # Do not change without reading `darwin-rebuild changelog`.
    primaryUser = settings.username;
    stateVersion = 6;

    ########################################################################
    # Mission Control / Spaces
    ########################################################################

    # Do not automatically rearrange Spaces based on most recent use
    # (System Settings > Desktop & Dock > Mission Control)
    defaults.dock.mru-spaces = false;

    # Disable "Displays have separate Spaces" (Aerospace recommends this OFF)
    # When false, spaces are shared across displays.
    defaults.spaces.spans-displays = false;

    # Disable "Switch to Space with open windows" when activating apps
    # Prevents macOS from jumping to the Space that contains an app's window.
    defaults.NSGlobalDomain.AppleSpacesSwitchOnActivate = false;

    # Common related options (commented):
    # Group windows by application in Mission Control (Exposé)
    # defaults.dock.expose-group-apps = true; # default: false
    #
    # Show Dashboard (legacy macOS only; generally not applicable on modern macOS)
    # defaults.dock.dashboard-in-overlay = true;

    ########################################################################
    # Dock
    ########################################################################

    # Autohide Dock and tune animation/delay
    defaults.dock.autohide = true; # auto-hide Dock when not in use
    defaults.dock.autohide-delay = 0.0; # delay before Dock hides (seconds)
    defaults.dock.autohide-time-modifier = 0.0; # animation duration (seconds)

    # Hide "recent applications" in Dock
    defaults.dock.show-recents = false;

    # Icon size in Dock (pixels)
    defaults.dock.tilesize = 48;

    # Common Dock options (commented):
    # Enable Dock magnification on hover
    # defaults.dock.magnification = true;
    #
    # Magnification size (only used if magnification = true)
    # defaults.dock.largesize = 64;
    #
    # Minimize effect: "genie", "scale", "suck"
    # defaults.dock.mineffect = "scale";
    #
    # Dock orientation: "left" | "bottom" | "right"
    # defaults.dock.orientation = "bottom";
    #
    # Highlight hover effect for stacks
    # defaults.dock.mouse-over-hilite-stack = true;
    #
    # Scroll up on Dock icon to show app windows (Exposé)
    # defaults.dock.scroll-to-open = true;
    #
    # Only show active apps (hides non-running apps)
    # defaults.dock.static-only = true;
    #
    # Manage Dock persistent items (apps/spacers/folders/files)
    # defaults.dock.persistent-apps = [
    #   { app = "/Applications/Safari.app"; }
    #   { spacer = { small = true; }; }
    # ];
    # defaults.dock.persistent-others = [
    #   { folder = "/System/Applications/Utilities"; }
    # ];

    ########################################################################
    # Finder
    ########################################################################

    # Show full POSIX path in Finder window titles
    defaults.finder._FXShowPosixPathInTitle = true;

    # Show all filename extensions in Finder
    defaults.finder.AppleShowAllExtensions = true;

    # Show hidden files in Finder
    defaults.finder.AppleShowAllFiles = true;

    # Default search scope: "SCev" (This Mac), "SCcf" (Current Folder), "SCsp" (Previous Scope)
    defaults.finder.FXDefaultSearchScope = "SCcf";

    # Show path bar (breadcrumbs) at bottom of Finder windows
    defaults.finder.ShowPathbar = true;

    # Show status bar at bottom of Finder windows
    defaults.finder.ShowStatusBar = true;

    # Preferred Finder view style:
    # "icnv" (Icon) | "Nlsv" (List) | "clmv" (Column) | "Flwv" (Gallery)
    defaults.finder.FXPreferredViewStyle = "Nlsv";

    # Common Finder options (commented):
    # Quit Finder via menu (adds Quit in Finder menu)
    # defaults.finder.QuitMenuItem = true;
    #
    # Keep folders on top when sorting by name
    # defaults.finder._FXSortFoldersFirst = true;
    #
    # Warn when changing a file extension
    # defaults.finder.FXEnableExtensionChangeWarning = false;
    #
    # Remove items from Trash after 30 days
    # defaults.finder.FXRemoveOldTrashItems = true;
    #
    # New window target:
    #  - "PfDe" (Desktop), "PfHm" (Home), "PfLo" (iCloud Drive), "PfCm" (Computer), "PfAF" (All My Files)
    # defaults.finder.NewWindowTarget = "PfHm";
    #
    # Target path used when NewWindowTarget = "PfLo" or others requiring a path
    # defaults.finder.NewWindowTargetPath = "file:///Users/${settings.username}/";

    ########################################################################
    # Global UI / Input (NSGlobalDomain)
    ########################################################################

    # Show hidden files globally in open/save panels (redundant with Finder domain, kept for convenience)
    defaults.NSGlobalDomain.AppleShowAllFiles = true;

    # Keyboard repeat timing
    # Lower is faster. InitialKeyRepeat is delay before repeating starts.
    defaults.NSGlobalDomain.InitialKeyRepeat = 15; # common values: 120, 94, 68, 35, 25, 15
    defaults.NSGlobalDomain.KeyRepeat = 2; # common values: 120, 90, 60, 30, 12, 6, 2

    # Disable Press-and-Hold accent menu (enables key repeating)
    defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;

    # Trackpad cursor tracking speed (0.0 to 3.0)
    defaults.NSGlobalDomain."com.apple.trackpad.scaling" = 3.0;

    # Disable window/panel animations for snappier feel
    defaults.NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;

    # Allow dragging a window by holding a modifier gesture (three-finger drag-like behavior)
    defaults.NSGlobalDomain.NSWindowShouldDragOnGesture = true;

    # Force 24-hour time (independent from region defaults)
    defaults.NSGlobalDomain.AppleICUForce24HourTime = true;

    # Menu bar visibility for full-screen apps (legacy; on newer macOS, see per-app behavior)
    defaults.NSGlobalDomain._HIHideMenuBar = false;

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
    # Software Update
    ########################################################################

    # Automatically install macOS software updates
    defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

    # Also enforce Software Update behaviors via CustomSystemPreferences below.

    ########################################################################
    # Trackpad (Pressure/Click thresholds and gestures)
    ########################################################################

    # Click weight (0 = light, 1 = medium (default), 2 = firm)
    defaults.trackpad.FirstClickThreshold = 0;

    # Force Click pressure (0 = light, 1 = medium (default), 2 = firm)
    defaults.trackpad.SecondClickThreshold = 0;

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
    # Custom System Preferences (System domains not covered above)
    ########################################################################

    # Use CustomSystemPreferences to write to specific domains with plist-like keys.
    defaults.CustomSystemPreferences = {
      # Developer/Debug menus in Safari
      "com.apple.Safari" = {
        WebKitDeveloperExtrasEnabledPreferenceKey = true;
        IncludeInternalDebugMenu = true;
        IncludeDevelopMenu = true;
      };

      # Encourage a stricter software update policy via domain keys
      "com.apple.SoftwareUpdate" = {
        AutomaticCheckEnabled = true; # enable automatic checking
        ScheduleFrequency = 1; # check daily
        AutomaticDownload = 1; # download updates in background
        CriticalUpdateInstall = 1; # install critical updates automatically
      };
    };

    ########################################################################
    # Custom User Preferences (Per-user domains and keys)
    ########################################################################

    # These are per-user preferences for the current user, useful for trackpad
    # gesture toggles that are stored in user-specific domains.
    defaults.CustomUserPreferences = {
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
    };

    ########################################################################
    # Keyboard mappings / modifiers
    ########################################################################

    # Enable keyboard mappings (required for below remaps)
    keyboard.enableKeyMapping = true;

    # Remap Caps Lock to Escape
    keyboard.remapCapsLockToEscape = true;

    # On non-US keyboards, remap the key to produce the tilde (~) more easily
    keyboard.nonUS.remapTilde = true;

    ########################################################################
    # Fn / Globe key action
    ########################################################################

    # Configure the Fn/Globe key action (requires restart to fully apply on some versions)
    # Options include: "Do Nothing", "Change Input Source", "Show Emoji & Symbols", "Start Dictation"
    # Fn/Globe key action is now configured under defaults.CustomUserPreferences."com.apple.HIToolbox" below

    ########################################################################
    # Optional: Apply settings immediately after switch (commented)
    ########################################################################
    # activationScripts = {
    #   postUserActivation = {
    #     "${settings.username}" = {
    #       text = ''
    #         # Reload system/user settings so changes to defaults take effect.
    #         /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    #       '';
    #     };
    #   };
    # };
  };
}
