{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.apps.discord;
in
{
  options.apps.discord.enable = mkEnableOption "Discord";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.discord ];
  };
}
