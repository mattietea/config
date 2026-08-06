{
  pkgs,
  ...
}:

{
  cachix.enable = false;

  languages.nix.enable = true;
  languages.nix.lsp.package = pkgs.nixd;

  packages = [
    pkgs.deadnix
    pkgs.nvfetcher
  ];

  # https://devenv.sh/scripts/
  scripts = {
    switch.exec = ''
      sudo darwin-rebuild switch --flake .
    '';

    # nvfetcher reads nvfetcher.toml and regenerates _sources/generated.nix
    # (pinned version + hash for pup, linear, oh-my-openagent, claude-mem, …).
    # One mechanism for every non-flake-input dependency — replaces the old
    # update-clis script.
    update.exec = ''
      set -euo pipefail
      ulimit -n 4096

      update_github_token="''${GH_TOKEN:-''${GITHUB_TOKEN:-}}"
      if [[ -z "$update_github_token" ]]; then
        update_github_token="$(${pkgs.gh}/bin/gh auth token 2>/dev/null || true)"
      fi
      update_nvfetcher_args=()
      if [[ -n "$update_github_token" ]]; then
        export NIX_CONFIG="''${NIX_CONFIG:-}
        extra-access-tokens = github.com=$update_github_token"

        update_nvchecker_keyfile="$(mktemp)"
        chmod 600 "$update_nvchecker_keyfile"
        trap 'rm -f "$update_nvchecker_keyfile"' EXIT
        printf '[keys]\n"github.com" = "%s"\n' "$update_github_token" > "$update_nvchecker_keyfile"
        update_nvfetcher_args=(--keyfile "$update_nvchecker_keyfile")
      fi

      devenv update
      nix flake update
      nvfetcher "''${update_nvfetcher_args[@]}"
    '';

    lint.exec = ''
      statix check .
    '';

    format.exec = ''
      treefmt
    '';

    # Run as the user: also expires home-manager/user profile generations,
    # which the root nix-gc daemon can't reach.
    clean.exec = ''
      nix-collect-garbage --delete-older-than 30d
    '';

    deadnix.exec = ''
      deadnix --no-lambda-pattern-names .
    '';
  };

  # Configure treefmt for formatting
  # Reference: https://devenv.sh/reference/options/#treefmtenable
  treefmt = {
    enable = true;
    config = {
      # nvfetcher owns _sources/* — don't reformat generated files (would churn
      # against nvfetcher's output on every update).
      settings.global.excludes = [ "_sources/*" ];
      programs = {
        nixfmt.enable = true;
        prettier = {
          enable = true;
          package = pkgs.prettier;
        };
        yamlfmt.enable = true;
      };
    };
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    treefmt.enable = true;
    shellcheck.enable = true;
    statix.enable = true;
    deadnix = {
      enable = true;
      settings.noLambdaPatternNames = true;
    };
    flake-check = {
      enable = true;
      entry = "nix flake check --no-build";
      pass_filenames = false;
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
