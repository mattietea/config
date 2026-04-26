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

    # NOTE: no nixpkgs follows — llm-agents ships pre-built binaries via cache.numtide.com;
    # overriding nixpkgs would invalidate their binary cache.
    llm-agents.url = "github:numtide/llm-agents.nix";

    claude-code-nix.url = "github:sadjow/claude-code-nix";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    agent-skills-nix.url = "github:Kyure-A/agent-skills-nix";
    agent-skills-nix.inputs.nixpkgs.follows = "nixpkgs";

    anthropic-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };

    vercel-skills-cli = {
      url = "github:vercel-labs/skills";
      flake = false;
    };

    pup-skills = {
      url = "github:datadog-labs/pup";
      flake = false;
    };

    linear-cli-skills = {
      url = "github:schpet/linear-cli";
      flake = false;
    };

    context7-skills = {
      url = "github:upstash/context7";
      flake = false;
    };

    agent-browser-skills = {
      url = "github:vercel-labs/agent-browser";
      flake = false;
    };

    wshobson-agents = {
      url = "github:wshobson/agents";
      flake = false;
    };

    worktrunk-skills = {
      url = "github:max-sixty/worktrunk";
      flake = false;
    };

    dot-skills = {
      url = "github:pproenca/dot-skills";
      flake = false;
    };

    chrome-devtools-mcp-skills = {
      url = "github:ChromeDevTools/chrome-devtools-mcp";
      flake = false;
    };

    itechmeat-skills = {
      url = "github:itechmeat/llm-code";
      flake = false;
    };

    humanlayer-skills = {
      url = "github:humanlayer/skills";
      flake = false;
    };

    superpowers = {
      url = "github:obra/superpowers";
      flake = false;
    };

    whatsapp-mcp-src = {
      url = "github:ewega/whatsapp-mcp/fix/whatsmeow-client-outdated";
      flake = false;
    };

  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" ];

      flake = {
        darwinConfigurations = {
          Castula-KQPN = import ./hosts/work.nix { inherit inputs; };
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
