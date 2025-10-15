{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.bun;
in
{
  options.pkgs.bun.enable = mkEnableOption "Bun";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.bun ];
  };
}
