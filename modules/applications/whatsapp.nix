{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.apps.whatsapp;
in
{
  options.apps.whatsapp.enable = mkEnableOption "WhatsApp";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.whatsapp-for-mac ];
  };
}
