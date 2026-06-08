_: {
  system.defaults = {
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

    CustomSystemPreferences."com.apple.SoftwareUpdate" = {
      AutomaticCheckEnabled = true;
      ScheduleFrequency = 1;
      AutomaticDownload = 1;
      CriticalUpdateInstall = 1;
    };
  };
}
