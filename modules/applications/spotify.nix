{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.apps.spotify;
in
{
  options.apps.spotify.enable = mkEnableOption "Spotify";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.spotify ];
  };
}
