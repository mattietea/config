{
  pkgs,
  settings,
  applicationNames,
  ...
}:
let
  homeApps = "/Users/${settings.username}/Applications/Home Manager Apps";
  dockutil = "${pkgs.dockutil}/bin/dockutil";

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
      appPath = "/System/Applications/Reminders.app";
    }
    {
      moduleName = null;
      appPath = "/Applications/Safari.app";
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

  dockPlist = "/Users/${settings.username}/Library/Preferences/com.apple.dock.plist";

  # Only touch Nix-managed apps (under homeApps) — system apps already have valid timestamps
  nixManagedApps = builtins.filter (
    e: builtins.substring 0 (builtins.stringLength homeApps) e.appPath == homeApps
  ) filteredApps;

  fixTimestamps = builtins.concatStringsSep "\n" (
    map (
      e: "  [ -d '${e.appPath}' ] && find '${e.appPath}' -exec touch -h {} + 2>/dev/null || true"
    ) nixManagedApps
  );

  addCommands = builtins.concatStringsSep "\n" (
    map (e: "  ${dockutil} --add '${e.appPath}' --no-restart '${dockPlist}'") filteredApps
  );
in
{
  home.packages = [ pkgs.dockutil ];

  # Run after Home Manager's copyApps to ensure apps exist with correct timestamps
  home.activation.configureDock = {
    after = [ "copyApps" ];
    before = [ ];
    data = ''
      echo "Configuring dock..."
      echo "Fixing app timestamps for macOS Sequoia compatibility..."
      ${fixTimestamps}
      echo "Updating dock entries..."
      ${dockutil} --remove all --no-restart '${dockPlist}'
      ${addCommands}
      /usr/bin/killall Dock
    '';
  };
}
