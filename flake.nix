{
  description = "mattietea's system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # NOTE: no nixpkgs follows — llm-agents ships pre-built binaries via cache.numtide.com;
    # overriding nixpkgs would invalidate their binary cache.
    llm-agents.url = "github:numtide/llm-agents.nix";

    # NOTE: no nixpkgs follows — claude-code-nix ships a prebuilt claude-code via
    # its own binary cache; overriding nixpkgs would force a source rebuild.
    claude-code-nix.url = "github:sadjow/claude-code-nix";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    agent-skills-nix.url = "github:Kyure-A/agent-skills-nix";
    agent-skills-nix.inputs.nixpkgs.follows = "nixpkgs";

    superpowers = {
      url = "github:obra/superpowers";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" ];

      flake = {
        overlays.default = import ./overlays;

        darwinConfigurations = {
          Castula-KQPN = import ./hosts/work.nix { inherit inputs; };
          Matts-Personal-Macbook-Air = import ./hosts/personal.nix { inherit inputs; };
        };
      };

      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt;
        };
    };
}
