{ pkgs, lib, config, inputs, ... }:

{
  cachix.enable = false;
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [ pkgs.git ];

  # https://devenv.sh/languages/
  # Enable Nix language support
  languages.nix.enable = true;
  # languages.rust.enable = true;

  # https://devenv.sh/processes/
  # processes.dev.exec = "${lib.getExe pkgs.watchexec} -n -- ls -la";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  scripts.update.exec = ''
    nix flake update
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # Configure treefmt for formatting
  # Reference: https://devenv.sh/reference/options/#treefmtenable
  treefmt = {
    enable = true;
    config = {
      # Enable nixpkgs-fmt for Nix file formatting
      programs.nixpkgs-fmt.enable = true;
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
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
