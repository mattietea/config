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

    opencode.url = "github:anomalyco/opencode/dev";
    opencode.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    agent-skills-nix.url = "github:Kyure-A/agent-skills-nix";
    agent-skills-nix.inputs.nixpkgs.follows = "nixpkgs";

    anthropic-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };

    vercel-skills = {
      url = "github:vercel-labs/agent-skills";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" ];

      flake = {
        darwinConfigurations = {
          Matts-Work-MacBook-Pro = import ./hosts/work.nix { inherit inputs; };
          Matts-Personal-Macbook-Air = import ./hosts/personal.nix { inherit inputs; };
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
        };
    };
}
