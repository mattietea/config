{ inputs, settings, ... }:
inputs.darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  specialArgs = {
    inherit inputs settings;
    user = "mattietea";
  };
  modules = [
    ../../modules/system/core
    ../../modules/system/darwin.nix
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";
        extraSpecialArgs = { inherit settings inputs; };
        sharedModules = [
          ../../modules/applications
          ../../modules/packages
          inputs.mac-app-util.homeManagerModules.default
        ];
      };
    }
    {
      networking.hostName = "Matts-Work-MacBook-Pro";
      home-manager.users.mattietea = {
        apps = {
          discord.enable = true;
          raycast.enable = true;
          spotify.enable = true;
          zed.enable = true;
        };
        pkgs = {
          bat.enable = true;
          delta.enable = true;
          dotenv.enable = true;
          eza.enable = true;
          fonts.enable = true;
          fzf.enable = true;
          gh.enable = true;
          git.enable = true;
          git-absorb.enable = true;
          git-machete.enable = true;
          graphite.enable = true;
          lazygit.enable = true;
          opencode.enable = true;
          pure.enable = true;
          rename-utils.enable = true;
          shopify.enable = true;
          tldr.enable = true;
          zsh.enable = true;
        };
      };
    }
  ];
}
