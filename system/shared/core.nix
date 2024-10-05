{
  config,
  lib,
  pkgs,
  settings,
  ...
}:

{

  nix = {
    configureBuildUsers = true;

    settings = {
      trusted-users = [ settings.username ];
      experimental-features = "nix-command flakes";
    };

    gc = {
      user = "root";
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

}
