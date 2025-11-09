{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.apps.ticktick;
in
{
  options.apps.ticktick.enable = mkEnableOption "TickTick";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.ticktick ];
  };
}
