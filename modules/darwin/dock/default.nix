{ settings, applicationNames, ... }:
let
  homeApps = "/Users/${settings.username}/Applications/Home Manager Apps";

  dockEntries = [
    {
      moduleName = null;
      appPath = "/System/Applications/Messages.app";
    }
    {
      moduleName = null;
      appPath = "/System/Applications/Mail.app";
    }
    {
      moduleName = "brave";
      appPath = "${homeApps}/Brave Browser.app";
    }
    {
      moduleName = "google-chrome";
      appPath = "${homeApps}/Google Chrome.app";
    }
    {
      moduleName = "discord";
      appPath = "${homeApps}/Discord.app";
    }
    {
      moduleName = "spotify";
      appPath = "${homeApps}/Spotify.app";
    }
    {
      moduleName = "zed";
      appPath = "${homeApps}/Zed.app";
    }
    {
      moduleName = null;
      appPath = "/System/Applications/System Settings.app";
    }
  ];

  filteredApps = builtins.filter (
    e: e.moduleName == null || builtins.elem e.moduleName applicationNames
  ) dockEntries;
in
{
  system.defaults.dock.persistent-apps = map (e: e.appPath) filteredApps;
}
