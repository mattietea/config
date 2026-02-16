{ inputs }:
let
  settings = {
    username = "mattietea";
    email = "mattcthomas@me.com";
    variables = {
      EDITOR = "nano";
      VISUAL = "nano";
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
    (app "utm")
    (app "ghostty")
  ];

  packages = [
    (pkg "agenix")
    (pkg "agent-skills")
    (pkg "aerospace")
    (pkg "bat")
    (pkg "bun")
    (pkg "claude-code")
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
