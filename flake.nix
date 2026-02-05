{
  description = "mattietea's system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    claude-code-nix.url = "github:sadjow/claude-code-nix";
    claude-code-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      flake = {
        darwinConfigurations = {
          Matts-Work-MacBook-Pro = import ./hosts/work { inherit inputs; };
          Matts-Personal-Macbook-Air = import ./hosts/personal { inherit inputs; };
        };
      };

      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt;

          devShells.default = pkgs.mkShell {
            buildInputs = [ pkgs.devenv ];
            shellHook = ''echo "Use 'devenv shell' for full environment"'';
          };

          checks.flake-schema = pkgs.runCommand "check" { } ''
            echo "Flake valid" && touch $out
          '';
        };
    };
}
