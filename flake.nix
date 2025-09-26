{
  description = "mattietea's system configuration file";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs =
    {
      self,
      darwin,
      nixpkgs,
      home-manager,
      mac-app-util,
      ...
    }@inputs:
    let
      # Utilities
      buildDarwin = import ./modules/utils/build-darwin.nix;

      # Settings
      settings = {
        # Used by git, might try and think of a better way
        username = "mattietea";
        email = "mattcthomas@me.com";
        variables = {
          EDITOR = "zed --wait";
          VISUAL = "zed --wait";
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
              ./modules/applications/spotify.nix
              ./modules/applications/raycast.nix
              ./modules/applications/zed.nix
              ./modules/packages/delta.nix
              ./modules/packages/lazygit.nix
              ./modules/packages/shopify.nix
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
              ./modules/applications/discord.nix
              ./modules/applications/spotify.nix
              ./modules/applications/raycast.nix
              ./modules/applications/zed.nix
              ./modules/packages/delta.nix
              ./modules/packages/lazygit.nix
              ./modules/packages/node.nix
              ./modules/packages/pnpm.nix
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

      # Formatter configuration
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
      formatter.x86_64-darwin = nixpkgs.legacyPackages.x86_64-darwin.nixfmt-rfc-style;

    };
}
