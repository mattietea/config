{ inputs, ... }:
let
  settings = import ../../lib/settings.nix;
  modules = import ../../lib/modules.nix { root = ../..; };
in
inputs.darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  specialArgs = {
    inherit inputs settings;
  };
  modules = [
    {
      nixpkgs.config.allowUnfree = true;
      nix.enable = false;

      users.users.${settings.username} = {
        name = settings.username;
        home = "/Users/${settings.username}";
      };
    }
    ../../modules/darwin/system
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";
        extraSpecialArgs = {
          inherit settings inputs;
        };
        sharedModules = modules.allPersonal;
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
    {
      networking.hostName = "Matts-Personal-Macbook-Air";
    }
  ];
}
