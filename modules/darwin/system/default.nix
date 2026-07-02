{ settings, ... }:
{
  imports = [
    ./dock.nix
    ./finder.nix
    ./input.nix
    ./nix.nix
    ./updates.nix
  ];

  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    primaryUser = settings.username;
    stateVersion = 6;

    # Screenshots and screen recordings (⇧⌘5 honors the same domain) land in
    # ~/Downloads instead of the Desktop. screencapture doesn't expand `~`, so
    # the path must be absolute.
    defaults.screencapture.location = "/Users/${settings.username}/Downloads";
  };
}
