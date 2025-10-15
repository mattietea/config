{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.graphite;
in
{
  options.pkgs.graphite.enable = mkEnableOption "graphite-cli";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.graphite-cli ];
  };
}
