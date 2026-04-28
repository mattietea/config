{ pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    # TODO: remove once nixpkgs-unstable includes zsh sigsuspend fix (NixOS/nixpkgs#513971)
    package = pkgs.direnv.overrideAttrs { doCheck = false; };
    enableZshIntegration = true;
    nix-direnv.enable = true;
    silent = true;
    config.global.warn_timeout = "30s";
  };
}
