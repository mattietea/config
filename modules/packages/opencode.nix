{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.opencode;
in
{
  options.pkgs.opencode.enable = mkEnableOption "opencode";

  config = mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      package = pkgs.opencode;
    };
  };
}
