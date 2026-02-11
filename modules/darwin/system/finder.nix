_:

{
  ########################################################################
  # Finder
  ########################################################################

  system.defaults.finder = {
    # Show full POSIX path in Finder window titles
    _FXShowPosixPathInTitle = true;
    # Show all filename extensions in Finder
    AppleShowAllExtensions = true;
    # Show hidden files in Finder
    AppleShowAllFiles = true;
    # Default search scope: "SCev" (This Mac), "SCcf" (Current Folder), "SCsp" (Previous Scope)
    FXDefaultSearchScope = "SCcf";
    # Show path bar (breadcrumbs) at bottom of Finder windows
    ShowPathbar = true;
    # Show status bar at bottom of Finder windows
    ShowStatusBar = true;
    # Preferred Finder view style:
    # "icnv" (Icon) | "Nlsv" (List) | "clmv" (Column) | "Flwv" (Gallery)
    FXPreferredViewStyle = "Nlsv";
  };

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
}
