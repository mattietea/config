{
  settings,
  pkgs,
  ...
}:

{
  # https://home-manager-options.extranix.com/?query=programs.eza&release=master

  programs.eza.enable = true;
  programs.eza.enableZshIntegration = true;

  programs.zsh.shellAliases = {
    ls = "${pkgs.eza}/bin/eza --oneline --icons --git --hyperlink";
    l = "ls --all";
    la = "l";
    tree = "ls --tree";
  };

  programs.zsh.initContent = ''
    # When we change directory, run the ls command
    function chpwd() {
      emulate -L zsh
      ${pkgs.eza}/bin/eza --grid --icons --git --hyperlink;
    }
  '';
}
