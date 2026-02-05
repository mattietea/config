{
  inputs,
  settings,
  hostname,
  system ? "aarch64-darwin",
  applications ? [ ],
  packages ? [ ],
}:

inputs.darwin.lib.darwinSystem {
  inherit system;
  specialArgs = { inherit inputs settings; };
  modules = [
    {
      nixpkgs.config.allowUnfree = true;
      nix.enable = false;
      users.users.${settings.username} = {
        name = settings.username;
        home = "/Users/${settings.username}";
      };
    }
    ../modules/darwin/system
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";
        extraSpecialArgs = { inherit settings inputs; };
        sharedModules = applications ++ packages;
        users.${settings.username} = {
          targets.darwin.copyApps.enable = true;
          home = {
            inherit (settings) username;
            homeDirectory = "/Users/${settings.username}";
            sessionVariables = settings.variables;
            stateVersion = "25.11";
          };
        };
      };
    }
    { networking.hostName = hostname; }
  ];
}
