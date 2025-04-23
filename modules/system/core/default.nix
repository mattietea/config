{ user
, ...
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
    enable = true;

    settings = {
      trusted-users = [ user ];
      experimental-features = "nix-command flakes";
    };

  };

}
