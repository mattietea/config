{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.bat;
in
{
  options.pkgs.bat.enable = mkEnableOption "bat";

  config = mkIf cfg.enable {
    programs.bat.enable = true;
  };
}
