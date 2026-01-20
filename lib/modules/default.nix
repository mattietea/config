# Shared module imports for all hosts
# Usage: import ../../lib/modules.nix { root = ../..; }
{ root }:
let
  app = name: root + "/modules/home-manager/applications/${name}";
  pkg = name: root + "/modules/home-manager/packages/${name}";
in
rec {
  # Applications
  applications = {
    # Core apps (all hosts)
    base = [
      (app "raycast")
      (app "zed")
      (app "spotify")
      (app "docker")
    ];
    # Personal-only apps
    personal = [
      (app "brave")
      (app "safari")
      (app "discord")
    ];
    # Commented out - available but not enabled
    # (app "logseq")
    # (app "whatsapp")
  };

  # Packages (all hosts)
  packages = {
    base = [
      (pkg "aerospace")
      (pkg "bat")
      (pkg "bun")
      (pkg "claude-code")
      (pkg "delta")
      (pkg "devenv")
      (pkg "direnv")
      (pkg "eza")
      (pkg "fonts")
      (pkg "fzf")
      (pkg "gh")
      (pkg "ghostty")
      (pkg "git")
      (pkg "git-absorb")
      (pkg "lazygit")
      (pkg "mise")
      (pkg "mole")
      (pkg "node")
      (pkg "opencode")
      (pkg "pure")
      (pkg "rename-utils")
      (pkg "tldr")
      (pkg "zoxide")
      (pkg "zsh")
    ];
    # Commented out - available but not enabled
    # (pkg "git-machete")
    # (pkg "starship")
    # (pkg "television")
    # (pkg "zellij")
    # (pkg "graphite")
    # (pkg "pnpm")
  };

  # Convenience combinations
  allBase = applications.base ++ packages.base;
  allPersonal = allBase ++ applications.personal;
  allWork = allBase; # Work uses base only (no brave/safari/discord)
}
