{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.pure;
in
{
  options.pkgs.pure.enable = mkEnableOption "Pure prompt";

  config = mkIf cfg.enable {
    programs.zsh.initContent = ''
      zstyle :prompt:pure:git:branch color yellow

      autoload -U promptinit; promptinit
      prompt pure
    '';

    programs.zsh.plugins = [
      {
        name = "pure";
        src = "${pkgs.pure-prompt}/share/zsh/site-functions";
      }
    ];
  };
}
