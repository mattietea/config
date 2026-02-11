_:

{
  ########################################################################
  # Software Update
  ########################################################################

  system.defaults = {
    # Automatically install macOS software updates
    SoftwareUpdate = {
      AutomaticallyInstallMacOSUpdates = true;
    };

    # Also enforce Software Update behaviors via CustomSystemPreferences below.
    CustomSystemPreferences = {
      "com.apple.SoftwareUpdate" = {
        AutomaticCheckEnabled = true; # enable automatic checking
        ScheduleFrequency = 1; # check daily
        AutomaticDownload = 1; # download updates in background
        CriticalUpdateInstall = 1; # install critical updates automatically
      };
    };
  };
}
