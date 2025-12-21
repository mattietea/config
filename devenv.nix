{ pkgs
, ...
}:

{
  cachix.enable = false;

  languages.nix.enable = true;
  languages.nix.lsp.package = pkgs.nixd;

  # https://devenv.sh/scripts/
  scripts = {
    switch.exec = ''
      sudo -i nix run nix-darwin -- switch --flake .
    '';

    update.exec = ''
      nix flake update
    '';

    lint.exec = ''
      statix check .
    '';

    format.exec = ''
      treefmt
    '';
  };

  # https://devenv.sh/tests/
  enterTest = ''
    nix flake check --no-build || exit 1
  '';

  # Configure treefmt for formatting
  # Reference: https://devenv.sh/reference/options/#treefmtenable
  treefmt = {
    enable = true;
    config = {
      programs = {
        nixpkgs-fmt.enable = true;
        prettier.enable = true;
        yamlfmt.enable = true;
      };
    };
  };

  # https://devenv.sh/git-hooks/
  # Configure git hooks for formatting and linting
  git-hooks = {
    enable = true;
    hooks = {
      # Enable treefmt for formatting (automatically uses treefmt config above)
      treefmt.enable = true;
      # Enable shellcheck for shell script linting
      shellcheck.enable = true;
      # Enable statix for Nix file linting
      statix.enable = true;
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
