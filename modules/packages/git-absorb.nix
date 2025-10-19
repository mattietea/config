{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.git-absorb;
in
{
  options.pkgs.git-absorb.enable = mkEnableOption "git-absorb";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.git-absorb ];

    programs.git.settings = {
      absorb = {
        maxStack = 40;
        oneFixupPerCommit = true;
        autoStageIfNothingStaged = true;
        forceAuthor = true;
      };

      alias.soak = "!git absorb --and-rebase";
    };
  };
}
