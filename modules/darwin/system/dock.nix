{
  settings,
  applicationNames,
  ...
}:
let
  homeApps = "/Users/${settings.username}/Applications/Home Manager Apps";

  # Dock entries. `moduleName` ties an entry to a home-manager application
  # module — entries whose module isn't imported on this host are dropped, so
  # each host's dock only shows apps it actually installs.
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
      moduleName = null;
      appPath = "/System/Applications/Calendar.app";
    }
    {
      moduleName = null;
      appPath = "/System/Applications/Reminders.app";
    }
    {
      moduleName = null;
      # /Applications/Safari.app is a symlink into the System Cryptex; the Dock
      # badges symlinked tiles with an alias arrow. Point at the real bundle.
      appPath = "/System/Cryptexes/App/System/Applications/Safari.app";
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
      moduleName = null;
      appPath = "${homeApps}/Ghostty.app";
    }
    {
      moduleName = "zed";
      appPath = "${homeApps}/Zed.app";
    }
    {
      moduleName = "opencode-desktop";
      appPath = "${homeApps}/OpenCode.app";
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
  system.defaults = {
    dock = {
      mru-spaces = false;
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.0;
      show-recents = false;
      tilesize = 48;

      # Fully declarative dock: the whole list is rewritten (and the Dock
      # restarted by nix-darwin) on every activation, so manual additions
      # don't survive a switch. Paths must be absolute — the Dock stores
      # them verbatim and won't expand `~`.
      persistent-apps = map (e: e.appPath) filteredApps;
      persistent-others = [ "/Users/${settings.username}/Downloads" ];
    };

    spaces.spans-displays = false;
  };
}
