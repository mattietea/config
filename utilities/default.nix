{ inputs }:
{
  mkDarwinHost =
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
            sharedModules =
              inputs.nixpkgs.lib.mapAttrsToList (name: _: ../modules/applications + "/${name}") (
                builtins.readDir ../modules/applications
              )
              ++ inputs.nixpkgs.lib.mapAttrsToList (name: _: ../modules/packages + "/${name}") (
                builtins.readDir ../modules/packages
              );
            users.${settings.username} = {
              inherit apps;
              pkgs = packages;
              home = {
                username = settings.username;
                homeDirectory = "/Users/${settings.username}";
                sessionVariables = settings.variables;
                stateVersion = "25.05";
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
