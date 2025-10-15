{ inputs }:
{
  hostname,
  settings,
  apps ? { },
  packages ? { },
}:

inputs.darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  specialArgs = {
    inherit inputs settings;
    user = settings.username;
  };
  modules = [
    ../modules/system/core
    ../modules/system/darwin.nix
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";
        extraSpecialArgs = { inherit settings inputs; };
        sharedModules = [
          ../modules/applications
          ../modules/packages
          inputs.mac-app-util.homeManagerModules.default
        ];
      };
    }
    {
      networking.hostName = hostname;
      home-manager.users.${settings.username} = {
        inherit apps;
        pkgs = packages;
        home.sessionVariables = settings.variables;
      };
    }
  ];
}
