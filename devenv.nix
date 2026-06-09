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
      rm -rf ~/Applications/Home\ Manager\ Apps/;
      sudo darwin-rebuild switch --flake .
    '';

    # nvfetcher reads nvfetcher.toml and regenerates _sources/generated.nix
    # (pinned version + hash for pup, linear, oh-my-openagent, …). One mechanism
    # for every non-flake-input dependency — replaces the old update-clis script.
    update.exec = ''
      devenv update;
      nix flake update;
      nvfetcher;
    '';

    lint.exec = ''
      statix check .
    '';

    format.exec = ''
      treefmt
    '';

    clean.exec = ''
      nix-collect-garbage
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
