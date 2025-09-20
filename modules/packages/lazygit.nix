{ pkgs, ... }:

{
  # https://home-manager-options.extranix.com/?query=programs.lazygit&release=master

  programs.lazygit.enable = true;

  programs.lazygit.settings = {
    autoFetch = false;
    git.paging.pager = "${pkgs.delta}/bin/delta --dark --paging=never";
  };

}
