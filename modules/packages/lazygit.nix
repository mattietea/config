{ pkgs, ... }:

{
  # https://home-manager-options.extranix.com/?query=programs.lazygit&release=master

  programs.lazygit.enable = true;

  programs.lazygit.settings = {
    autoFetch = false;
    git = {
      fetchAll = false;
      paging.pager = "${pkgs.delta}/bin/delta --light --paging=never";
    };
    gui = {
      nerdFontsVersion = 3;
      showCommandLog = false;
      border = "single";
      skipStashWarning = true;
      filterMode = "fuzzy";
      commitHashLength = 4;
    };
  };

}
