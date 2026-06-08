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
  };
}
