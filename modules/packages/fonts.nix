{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.fonts;
in
{
  options.pkgs.fonts.enable = mkEnableOption "Nerd Fonts collection";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nerd-fonts.geist-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg
      nerd-fonts.hack
      nerd-fonts.iosevka
    ];

    fonts.fontconfig.enable = true;
  };
}
