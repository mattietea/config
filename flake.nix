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
      self,
      darwin,
      nixpkgs,
      home-manager,
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
          EDITOR = "cursor";
          VISUAL = "cursor";
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
              ./modules/packages/starship.nix
              ./modules/packages/neovim.nix
              ./modules/packages/gh.nix
              ./modules/packages/bat.nix
              ./modules/packages/git-absorb.nix
              ./modules/programs/alacritty
            ];
          };
        };

        Matts-Personal-MacBook-Pro = buildDarwin {
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
              ./modules/packages/starship.nix
              ./modules/packages/neovim.nix
              ./modules/packages/gh.nix
              ./modules/packages/bat.nix
              ./modules/packages/git-absorb.nix
              ./modules/programs/alacritty.nix
            ];
          };
        };
      };

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
    };
}
