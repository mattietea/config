{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.starship;
in
{
  options.pkgs.starship.enable = mkEnableOption "Starship prompt";

  config = mkIf cfg.enable {
    programs.starship.enable = true;
    programs.starship.enableZshIntegration = true;
  };
}
