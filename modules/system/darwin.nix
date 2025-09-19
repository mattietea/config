{ user
, ...
}:

{

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    primaryUser = user;

    # https://github.com/nix-community/home-manager/blob/master/modules/system/darwin-settings.nix
    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 6;

    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    # activationScripts.postUserActivation.${user}.text = ''
    #   # activateSettings -u will reload the settings from the database and apply them to the current session,
    #   # so we do not need to logout and login again to make the changes take effect.
    #   /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    # '';

    defaults.dock.autohide = true;
    defaults.dock.autohide-delay = 0.1;
    defaults.dock.autohide-time-modifier = 0.1;
    defaults.dock.show-recents = false;
    defaults.dock.tilesize = 48;

    # Whether to automatically rearrange spaces based on most recent use
    defaults.dock.mru-spaces = false;

    defaults.NSGlobalDomain._HIHideMenuBar = false;

    # Whether to show the full filepath in the window title
    defaults.finder._FXShowPosixPathInTitle = true;
    defaults.finder.AppleShowAllExtensions = true;
    defaults.finder.AppleShowAllFiles = true;
    defaults.finder.FXDefaultSearchScope = "SCcf";

    # Show path breadcrumbs in finder windows
    defaults.finder.ShowPathbar = true;

    # Show status bar at bottom of finder windows with item/disk space stats
    defaults.finder.ShowStatusBar = true;

    # Change the default finder view
    # "icnv" = Icon view, "Nlsv" = List view, "clmv" = Column View, "Flwv" = Gallery View The default is icnv
    defaults.finder.FXPreferredViewStyle = "Nlsv";

    # Automatically install Mac OS software updates
    defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

    # Displays have separate Spaces
    defaults.spaces.spans-displays = false;

    # For normal click: 0 for light clicking, 1 for medium, 2 for firm. The default is 1.
    defaults.trackpad.FirstClickThreshold = 0;
    # For force touch: 0 for light clicking, 1 for medium, 2 for firm. The default is 1.
    defaults.trackpad.SecondClickThreshold = 0;

    defaults.NSGlobalDomain.AppleShowAllFiles = true;

    # This sets how long you must hold down the key before it starts repeating.
    # 120, 94, 68, 35, 25, 15 (lower is faster)
    defaults.NSGlobalDomain.InitialKeyRepeat = 15;

    # This sets how fast it repeats once it starts.
    # 120, 90, 60, 30, 12, 6, 2 (lower is faster)
    defaults.NSGlobalDomain.KeyRepeat = 2;

    # Whether to enable the press-and-hold feature
    defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;

    # Configures the trackpad tracking speed (0 to 3). The default is "1".s
    defaults.NSGlobalDomain."com.apple.trackpad.scaling" = 3.0;

    defaults.NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;

    # Whether to use 24-hour or 12-hour time. The default is based on region settings.
    defaults.NSGlobalDomain.AppleICUForce24HourTime = true;

    defaults.CustomSystemPreferences = {
      "com.apple.Safari" = {
        WebKitDeveloperExtrasEnabledPreferenceKey = true;
        IncludeInternalDebugMenu = true;
        IncludeDevelopMenu = true;
      };
      "com.apple.SoftwareUpdate" = {
        AutomaticCheckEnabled = true;
        ScheduleFrequency = 1;
        AutomaticDownload = 1;
        CriticalUpdateInstall = 1;
      };
    };

    # Whether to enable keyboard mappings. (The below wont work if not)
    keyboard.enableKeyMapping = true;

    # Whether to remap the Caps Lock key to Escape.
    keyboard.remapCapsLockToEscape = true;

    # Whether to remap the Tilde key on non-us keyboards.
    keyboard.nonUS.remapTilde = true;
  };
}
