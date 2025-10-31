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
        Matts-Work-MacBook-Pro = import ./hosts/work { mkDarwinHost = utilities.mkDarwinHost; };
        Matts-Personal-Macbook-Air = import ./hosts/personal { mkDarwinHost = utilities.mkDarwinHost; };
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
    };
}
