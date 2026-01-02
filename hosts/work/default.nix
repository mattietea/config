{ inputs, ... }:
let
  settings = {
    username = "mattietea";
    email = "mattcthomas@me.com";
    variables = {
      EDITOR = "zed --wait";
      VISUAL = "zed --wait";
    };
  };
in
inputs.darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  specialArgs = {
    inherit inputs settings;
  };
  modules = [
    {
      nixpkgs.config.allowUnfree = true;
      nix.enable = false;

      users.users.${settings.username} = {
        name = settings.username;
        home = "/Users/${settings.username}";
      };
    }
    ../../modules/darwin/system
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";
        extraSpecialArgs = {
          inherit settings inputs;
        };
        sharedModules = [
          # Applications
          ../../modules/home-manager/applications/raycast
          ../../modules/home-manager/applications/spotify
          ../../modules/home-manager/applications/zed
          # ../../modules/home-manager/applications/logseq
          # Packages
          ../../modules/home-manager/packages/aerospace
          ../../modules/home-manager/packages/bat
          ../../modules/home-manager/packages/bun
          ../../modules/home-manager/packages/delta
          ../../modules/home-manager/packages/direnv
          ../../modules/home-manager/packages/devenv
          ../../modules/home-manager/packages/eza
          ../../modules/home-manager/packages/fonts
          ../../modules/home-manager/packages/fzf
          ../../modules/home-manager/packages/gh
          ../../modules/home-manager/packages/git
          ../../modules/home-manager/packages/git-absorb
          # ../../modules/home-manager/packages/git-machete
          ../../modules/home-manager/packages/lazygit
          ../../modules/home-manager/packages/opencode
          ../../modules/home-manager/packages/pure
          ../../modules/home-manager/packages/rename-utils
          ../../modules/home-manager/packages/shopify
          ../../modules/home-manager/packages/tldr
          ../../modules/home-manager/packages/zsh
        ];

        users.${settings.username} = {
          targets.darwin.copyApps.enable = true;
          home = {
            inherit (settings) username;
            homeDirectory = "/Users/${settings.username}";
            sessionVariables = settings.variables;
            stateVersion = "25.11";
          };
        };
      };
    }
    {
      networking.hostName = "Matts-Work-MacBook-Pro";
    }
  ];
}
