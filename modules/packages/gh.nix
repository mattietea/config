{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.gh;
in
{
  options.pkgs.gh.enable = mkEnableOption "GitHub CLI (gh)";

  config = mkIf cfg.enable {
    programs.gh.enable = true;
    programs.gh.gitCredentialHelper.enable = true;
  };
}
