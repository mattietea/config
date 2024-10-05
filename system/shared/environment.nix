{
  config,
  lib,
  pkgs,
  settings,
  ...
}:

{

  users = {
    # Set the home directory for the user
    users.${settings.username}.home = "/Users/${settings.username}";
  };

  # TODO: Is this needed?
  programs = {
    zsh.enable = true;
    zsh.enableCompletion = false;
  };

  # List packages installed in system profile (All users)
  environment = {
    systemPackages = (import ../../shared/packages.nix { inherit pkgs; });

    shells = [
      pkgs.zsh
      pkgs.bash
    ];

    loginShell = pkgs.zsh;

    variables = settings.variables;
  };

}
