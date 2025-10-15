{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.dotenv;
in
{
  options.pkgs.dotenv.enable = mkEnableOption "devenv";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.devenv ];
  };
}
