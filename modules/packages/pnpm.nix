{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.pnpm;
in
{
  options.pkgs.pnpm.enable = mkEnableOption "pnpm";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.pnpm ];
  };
}
