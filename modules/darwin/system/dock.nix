_:

{
  ########################################################################
  # Mission Control / Spaces / Dock
  ########################################################################

  system.defaults = {
    # Do not automatically rearrange Spaces based on most recent use
    # (System Settings > Desktop & Dock > Mission Control)
    dock = {
      mru-spaces = false;
      # Autohide Dock and tune animation/delay
      autohide = true; # auto-hide Dock when not in use
      autohide-delay = 0.0; # delay before Dock hides (seconds)
      autohide-time-modifier = 0.0; # animation duration (seconds)
      # Hide "recent applications" in Dock
      show-recents = false;
      # Icon size in Dock (pixels)
      tilesize = 48;
    };

    # Disable "Displays have separate Spaces" (Aerospace recommends this OFF)
    # When false, spaces are shared across displays.
    spaces = {
      spans-displays = false;
    };

    # Common related options (commented):
    # Group windows by application in Mission Control (Exposé)
    # defaults.dock.expose-group-apps = true; # default: false
    #
    # Show Dashboard (legacy macOS only; generally not applicable on modern macOS)
    # defaults.dock.dashboard-in-overlay = true;

    ########################################################################
    # Dock
    ########################################################################

    # Common Dock options (commented):

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
  };
}
