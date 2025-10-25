{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.zellij;
in
{
  options.pkgs.zellij.enable = mkEnableOption "Zellij prompt";

  config = mkIf cfg.enable {
    programs.zellij.enable = true;
    programs.zellij.enableZshIntegration = true;

    programs.zellij.settings = {
    };
  };
}
