{ pkgs, ... }:
{
  home.packages = with pkgs; [
    git-absorb
  ];

  programs.git.extraConfig = {

    # https://github.com/tummychow/git-absorb?tab=readme-ov-file#configuration

    absorb = {
      maxStack = 40;
      oneFixupPerCommit = true;
      autoStageIfNothingStaged = true;
      forceAuthor = true;
    };
  };

  programs.git.aliases = {
    soak = "!git absorb --and-rebase";
  };
}
