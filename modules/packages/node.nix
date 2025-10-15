{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.node;
in
{
  options.pkgs.node.enable = mkEnableOption "Node.js";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.nodejs ];
  };
}
