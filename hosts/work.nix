{ inputs }:
let
  settings = {
    username = "matthewthomas";
    name = "Matthew Thomas";
    github = "mattietea-harvey";
    email = "matthew.thomas@harvey.ai";
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
  hostname = "Castula-KQPN";

  applications = [
    # (app "google-chrome")
    # (app "raycast")
    # (app "spotify")
    (app "ghostty")
    (app "zed")
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
    (pkg "linear")
    (pkg "mise")
    (pkg "node")
    (pkg "pup")
    (pkg "pure")
    (pkg "rename-utils")
    (pkg "sentry")
    (pkg "tldr")
    (pkg "worktrunk-work")
    (pkg "zoxide")
    (pkg "zsh")
  ];

  ai = [
    ../modules/ai
    ../modules/ai/work.nix
  ];
}
