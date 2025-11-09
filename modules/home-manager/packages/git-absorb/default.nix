{
  pkgs,
  ...
}:
{
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
}
