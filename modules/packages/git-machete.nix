{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.git-machete;
in
{
  options.pkgs.git-machete.enable = mkEnableOption "git-machete";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.git-machete ];
    programs.git.aliases.m = "machete";
  };
}
