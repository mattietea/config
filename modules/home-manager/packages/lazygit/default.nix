{ pkgs
, ...
}:
{
  programs.lazygit.enable = true;

  programs.lazygit.settings = {
    git = {
      autoFetch = false;
      fetchAll = false;
      pagers = [{ pager = "${pkgs.delta}/bin/delta --light --paging=never"; }];
    };
    gui = {
      nerdFontsVersion = "3";
      showCommandLog = false;
      border = "single";
      skipStashWarning = true;
      filterMode = "fuzzy";
      commitHashLength = 4;
    };
  };
}
