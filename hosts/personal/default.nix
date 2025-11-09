{ mkDarwinHost }:
mkDarwinHost {
  hostname = "Matts-Personal-Macbook-Air";

  settings = {
    username = "mattietea";
    email = "mattcthomas@me.com";
    variables = {
      EDITOR = "zed --wait";
      VISUAL = "zed --wait";
    };
  };

  apps = [
    ../../modules/applications/discord.nix
    ../../modules/applications/raycast.nix
    ../../modules/applications/spotify.nix
    ../../modules/applications/zed.nix
    ../../modules/applications/whatsapp.nix
  ];

  packages = [
    ../../modules/packages/bun.nix
    ../../modules/packages/bat.nix
    ../../modules/packages/delta.nix
    ../../modules/packages/dotenv.nix
    ../../modules/packages/eza.nix
    ../../modules/packages/fonts.nix
    ../../modules/packages/fzf.nix
    ../../modules/packages/gh.nix
    ../../modules/packages/git.nix
    ../../modules/packages/git-absorb.nix
    ../../modules/packages/git-machete.nix
    ../../modules/packages/lazygit.nix
    ../../modules/packages/opencode.nix
    ../../modules/packages/pure.nix
    ../../modules/packages/rename-utils.nix
    ../../modules/packages/shopify.nix
    ../../modules/packages/tldr.nix
    ../../modules/packages/zsh.nix
    ../../modules/packages/aerospace.nix
  ];
}
