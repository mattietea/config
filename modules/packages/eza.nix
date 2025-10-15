{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.eza;
in
{
  options.pkgs.eza.enable = mkEnableOption "eza";

  config = mkIf cfg.enable {
    programs.eza.enable = true;
    programs.eza.enableZshIntegration = true;
    programs.eza.git = true;

    programs.zsh.shellAliases = {
      ls = "${pkgs.eza}/bin/eza --oneline --icons --git";
      l = "ls --all";
      la = "l";
      tree = "ls --tree";
    };

    programs.zsh.initContent = ''
      # When we change directory, run the ls command
      function chpwd() {
        emulate -L zsh
        ${pkgs.eza}/bin/eza --grid --icons --git;
      }
    '';
  };
}
