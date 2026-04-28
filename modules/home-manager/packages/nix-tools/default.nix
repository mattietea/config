{
  pkgs,
  ...
}:
{
  home.packages = [
    # Formatting
    pkgs.treefmt
    pkgs.nixfmt
    pkgs.prettier
    pkgs.yamlfmt

    # Linting
    pkgs.statix
    pkgs.deadnix
    pkgs.shellcheck

    # Language server
    pkgs.nixd

    # Utilities
    pkgs.jq
  ];
}
