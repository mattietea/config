{
  description = "mattietea's system configuration file";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs =
    {
      nixpkgs,
      ...
    }@inputs:
    let
      mkDarwinHost = import ./lib/mkDarwinHost.nix { inherit inputs; };
    in
    {
      darwinConfigurations = {
        work = import ./hosts/work { inherit mkDarwinHost; };
        personal = import ./hosts/personal { inherit mkDarwinHost; };

        # Compatibility aliases for hostname-based switching
        Matts-Work-MacBook-Pro = import ./hosts/work { inherit mkDarwinHost; };
        Matts-Personal-Macbook = import ./hosts/personal { inherit mkDarwinHost; };
      };

      formatter = nixpkgs.lib.genAttrs (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
