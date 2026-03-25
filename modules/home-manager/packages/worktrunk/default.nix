{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.worktrunk ];

  programs.zsh.initExtra = ''
    eval "$(${pkgs.worktrunk}/bin/wt config shell init zsh)"
  '';
}
