{ inputs }:
let
  settings = {
    username = "mattietea";
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
    (app "opencode-desktop")
    (app "raycast")
    (app "safari")
    (app "spotify")
    (app "zed")
  ];

  packages = [
    (pkg "agent-skills")
    (pkg "aerospace")
    (pkg "bat")
    (pkg "bun")
    (pkg "claude-code")
    (pkg "delta")
    (pkg "devenv")
    (pkg "direnv")
    (pkg "docker")
    (pkg "eza")
    (pkg "fonts")
    (pkg "fzf")
    (pkg "gh")
    (pkg "ghostty")
    (pkg "git")
    (pkg "git-absorb")
    (pkg "lazygit")
    (pkg "mcp")
    (pkg "mise")
    (pkg "node")
    (pkg "opencode")
    (pkg "pure")
    (pkg "rename-utils")
    (pkg "tldr")
    (pkg "zoxide")
    (pkg "zsh")
  ];
}
