{
  user,
  lib,
  config,
  ...
}:
{
  options.unfreePackages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Names (lib.getName) of unfree packages allowed per host";
  };

  config = {
    # User accounts
    users = {
      users.${user} = {
        name = user;
        home = "/Users/${user}";
      };
    };

    # Nixpkgs policy
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfreePackages;

    # Home Manager: centralize stateVersion (mkDefault to avoid conflicts)
    home-manager.users.${user}.home.stateVersion = lib.mkDefault "25.05";

    # Determinate Systems nix-darwin agent disabled by default
    nix = {
      enable = false;
    };
  };
}
