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

  # nix-darwin rewrites the Downloads tile on every activation, resetting its
  # stack sort to Name. persistent-others carries no sort option, so patch
  # arrangement (2 = Date Added) into the tile afterwards; home-manager
  # activation runs after the system defaults + Dock restart.
  home-manager.users.${settings.username}.home.activation.dockDownloadsSortByDateAdded = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      dockPlist="$HOME/Library/Preferences/com.apple.dock.plist"
      if /usr/libexec/PlistBuddy -c "Print :persistent-others:0:tile-data:file-data:_CFURLString" "$dockPlist" 2>/dev/null | grep -q "/Downloads"; then
        current=$(/usr/libexec/PlistBuddy -c "Print :persistent-others:0:tile-data:arrangement" "$dockPlist" 2>/dev/null || echo missing)
        if [ "$current" != "2" ]; then
          /usr/libexec/PlistBuddy -c "Set :persistent-others:0:tile-data:arrangement 2" "$dockPlist" 2>/dev/null ||
            /usr/libexec/PlistBuddy -c "Add :persistent-others:0:tile-data:arrangement integer 2" "$dockPlist"
          /usr/bin/killall Dock || true
        fi
      fi
    '';
  };
}
