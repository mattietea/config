{ inputs }:
{
  mkDarwinHost =
    {
      hostname,
      settings,
      apps ? [ ],
      packages ? [ ],
    }:

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
        ../system/darwin.nix
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "bak";
            extraSpecialArgs = {
              inherit settings inputs;
            };
            sharedModules = apps ++ packages;
            users.${settings.username} = {
              targets.darwin.copyApps.enable = true;
              home = {
                username = settings.username;
                homeDirectory = "/Users/${settings.username}";
                sessionVariables = settings.variables;
                stateVersion = "25.11";
              };
            };
          };
        }
        {
          networking.hostName = hostname;
        }
      ];
    };
}
