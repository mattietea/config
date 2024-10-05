{
  description = "System flake configuration file";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }: {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Matts-Personal-MacBook-Pro
    darwinConfigurations."Matts-Personal-MacBook-Pro" =
      nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./configuration.nix

          home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.mattietea = import ./home.nix;
              home-manager.backupFileExtension = "backup";
            }
        ];
      };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Matts-Personal-MacBook-Pro".pkgs;
  };
}
