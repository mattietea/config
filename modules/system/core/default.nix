{
  user,
  ...
}:

{

  imports = [
    ./environment.nix
  ];

  users = {
    # Set the home directory for the user
    users.${user} = {
      name = user;
      home = "/Users/${user}";
    };
  };

  nixpkgs.config.allowUnfree = true;

  nix = {
    configureBuildUsers = true;

    settings = {
      trusted-users = [ user ];
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
