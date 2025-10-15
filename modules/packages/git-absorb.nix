{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.git-absorb;
in
{
  options.pkgs.git-absorb.enable = mkEnableOption "git-absorb";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.git-absorb ];

    programs.git.extraConfig.absorb = {
      maxStack = 40;
      oneFixupPerCommit = true;
      autoStageIfNothingStaged = true;
      forceAuthor = true;
    };

    programs.git.aliases.soak = "!git absorb --and-rebase";
  };
}
