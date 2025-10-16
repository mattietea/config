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
      utilities = import ./utilities { inherit inputs; };
    in
    {
      darwinConfigurations = {
        work = import ./hosts/work { mkDarwinHost = utilities.mkDarwinHost; };
        personal = import ./hosts/personal { mkDarwinHost = utilities.mkDarwinHost; };

        # Compatibility aliases for hostname-based switching
        Matts-Work-MacBook-Pro = import ./hosts/work { mkDarwinHost = utilities.mkDarwinHost; };
        Matts-Personal-Macbook = import ./hosts/personal { mkDarwinHost = utilities.mkDarwinHost; };
      };

      formatter = nixpkgs.lib.genAttrs (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
