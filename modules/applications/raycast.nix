{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.apps.raycast;
in
{
  options.apps.raycast.enable = mkEnableOption "Raycast";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.raycast ];
  };
}
