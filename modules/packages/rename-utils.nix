{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.rename-utils;
in
{
  options.pkgs.rename-utils.enable = mkEnableOption "renameutils";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.renameutils ];
    programs.zsh.shellAliases.rename = "${pkgs.renameutils}/bin/qmv -f do";
  };
}
