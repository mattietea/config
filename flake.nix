{
  description = "mattietea's system configuration file";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      darwin,
      nixpkgs,
      home-manager,
      nixvim,
      ...
    }@inputs:
    let
      # Utilities
      buildDarwin = import ./modules/utils/build-darwin.nix;

      # Settings
      settings = {
        # Used git, might try and think of a better way
        username = "mattietea";
        email = "mattcthomas@me.com";
        variables = {
          EDITOR = "nvim";
          VISUAL = "cursor --wait";
        };
      };
    in
    {
      darwinConfigurations = {
        # scutil --get LocalHostName
        Matts-Work-MacBook-Pro = buildDarwin {
          user = "mattietea";
          settings = settings;
          inputs = inputs;
          modules = {
            system = [
              ./modules/system/core
              ./modules/system/darwin.nix
            ];
            user = [
              ./modules/packages/fonts.nix
              ./modules/packages/git.nix
              ./modules/packages/zsh.nix
              ./modules/packages/eza.nix
              ./modules/packages/fzf.nix
              ./modules/packages/pure.nix
              ./modules/packages/gh.nix
              ./modules/packages/bat.nix
              ./modules/packages/rename-utils.nix
              ./modules/packages/git-absorb.nix
              ./modules/packages/git-machete.nix
              ./modules/packages/tldr.nix
              ./modules/packages/graphite.nix
            ];
          };
        };

        Matts-Personal-Macbook = buildDarwin {
          user = "mattietea";
          settings = settings;
          inputs = inputs;
          modules = {
            system = [
              ./modules/system/core
              ./modules/system/darwin.nix
            ];
            user = [
              ./modules/packages/fonts.nix
              ./modules/packages/git.nix
              ./modules/packages/zsh.nix
              ./modules/packages/eza.nix
              ./modules/packages/fzf.nix
              ./modules/packages/pure.nix
              ./modules/packages/gh.nix
              ./modules/packages/bat.nix
              ./modules/packages/rename-utils.nix
              ./modules/packages/git-absorb.nix
              ./modules/packages/git-machete.nix
              ./modules/packages/tldr.nix
            ];
          };
        };
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
    };
}
