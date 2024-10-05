{
  description = "mattietea's system configuration file";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
    }:
    let
      settings = {
        name = "Matt Thomas";
        # $ id -un
        # This is used to configure your systems `user`
        # but is also used to configure things like git ect.
        # If you're github username and systems user is different
        # look for references to `settings.username` and update them
        username = "mattietea";
        email = "mattcthomas@me.com";
        variables = {
          EDITOR = "cursor";
          VISUAL = "cursor";
        };
      };
    in
    {
      darwinConfigurations.mac = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./system/macos.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mattietea = import ./modules/home.nix;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {
              inherit settings;
            };
          }
        ];
        specialArgs = {
          inherit settings;
        };
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
    };
}
