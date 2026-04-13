{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.git-machete ];

  programs.git.settings = {
    alias.m = "machete";
    machete = {
      traverse.whenBranchNotCheckedOutInAnyWorktree = "stay-in-the-current-worktree";
      worktree.useTopLevelMacheteFile = true;
      status.extraSpaceBeforeBranchName = true;
      github.annotateWithUrls = true;
      github.prDescriptionIntroStyle = "full";
    };
  };
}
