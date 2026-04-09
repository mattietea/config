{ inputs }:
let
  settings = {
    username = "mattietea";
    name = "Matt Thomas";
    github = "mattietea";
    email = "mattcthomas@me.com";
    variables = {
      EDITOR = "zed --wait";
      VISUAL = "zed --wait";
    };
  };

  mkHost = import ../lib/mkHost.nix;
  app = name: ../modules/home-manager/applications/${name};
  pkg = name: ../modules/home-manager/packages/${name};
in
mkHost {
  inherit inputs settings;
  hostname = "Matts-Personal-Macbook-Air";

  applications = [
    (app "brave")
    (app "discord")
    (app "google-chrome")
    (app "raycast")
    (app "safari")
    (app "spotify")
    (app "utm")
    (app "zed")
    (app "ghostty")
  ];

  packages = [
    (pkg "agenix")
    (pkg "aerospace")
    (pkg "bat")
    (pkg "bun")
    (pkg "dock")
    (pkg "delta")
    (pkg "devenv")
    (pkg "direnv")

    (pkg "eza")
    (pkg "fonts")
    (pkg "fzf")
    (pkg "gh")
    (pkg "git")
    (pkg "git-absorb")
    (pkg "git-machete")
    (pkg "lazygit")
    (pkg "mise")
    (pkg "node")
    (pkg "pure")
    (pkg "rename-utils")
    (pkg "tldr")
    (pkg "tmux")
    (pkg "zoxide")
    (pkg "zsh")
  ];

  ai = [
    ../modules/ai
    ../modules/ai/personal.nix
  ];
}
