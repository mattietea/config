{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.worktrunk ];

  programs.zsh.initContent = ''
    eval "$(${pkgs.worktrunk}/bin/wt config shell init zsh)"
  '';
}
