{ mkDarwinHost }:

mkDarwinHost {
  hostname = "Matts-Work-MacBook-Pro";

  settings = {
    username = "mattietea";
    email = "mattcthomas@me.com";
    variables = {
      EDITOR = "zed --wait";
      VISUAL = "zed --wait";
    };
  };

  apps = {
    raycast.enable = true;
    spotify.enable = true;
    zed.enable = true;
  };

  packages = {
    bun.enable = true;
    bat.enable = true;
    delta.enable = true;
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
    tldr.enable = true;
    zsh.enable = true;
    shopify.enable = true;
  };
}
