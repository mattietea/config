{
  config,
  lib,
  pkgs,
  settings,
  ...
}:

{
  imports = [
    ./programs/git.nix
    ./programs/zsh.nix
    ./programs/eza.nix
    ./programs/fzf.nix
    ./programs/starship.nix
    ./programs/neovim.nix
    ./programs/gh.nix
    ./programs/bat.nix
  ];

  home.stateVersion = "24.05";
  
}
