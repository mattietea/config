{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.apps.notion;
in
{
  options.apps.notion.enable = mkEnableOption "Notion";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.notion-app ];
  };
}
