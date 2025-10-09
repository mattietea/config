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
    # https://docs.determinate.systems/guides/nix-darwin/
    enable = false;
  };

}
