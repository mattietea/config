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
  ];

  # https://devenv.sh/scripts/
  scripts = {
    switch.exec = ''
      rm -rf ~/Applications/Home\ Manager\ Apps/;
      sudo darwin-rebuild switch --flake .
    '';

    update.exec = ''
      devenv update;
      nix flake update;
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
      programs = {
        nixfmt.enable = true;
        prettier.enable = true;
        yamlfmt.enable = true;
      };
    };
  };

  # https://devenv.sh/git-hooks/
  # Configure git hooks for formatting and linting
  git-hooks = {
    enable = true;
    package = pkgs.pre-commit;
    hooks = {
      # Enable treefmt for formatting (automatically uses treefmt config above)
      treefmt.enable = true;
      # Enable shellcheck for shell script linting
      shellcheck.enable = true;
      # Enable statix for Nix file linting
      statix.enable = true;
      # Enable deadnix for unused code detection
      deadnix = {
        enable = true;
        settings = {
          noLambdaPatternNames = true;
        };
      };
      # Validate flake on commit
      flake-check = {
        enable = true;
        entry = "nix flake check --no-build";
        pass_filenames = false;
      };
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
