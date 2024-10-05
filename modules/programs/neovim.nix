{
  config,
  ...
}:

{
  # https://home-manager-options.extranix.com/?query=programs.neovim.enable&release=master

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = false;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;
  programs.neovim.vimdiffAlias = true;
}
