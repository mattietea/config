{ pkgs, ... }:
{
  home.packages = with pkgs; [
    git-absorb
  ];

  programs.git.extraConfig = {

    # https://github.com/tummychow/git-absorb?tab=readme-ov-file#configuration

    absorb = {
      maxStack = 30;
      oneFixupPerCommit = true;
      autoStageIfNothingStaged = true;
    };
  };

  programs.git.aliases = {
    soak = "!git absorb --and-rebase --base $(git merge-base HEAD origin/main)";
  };
}
