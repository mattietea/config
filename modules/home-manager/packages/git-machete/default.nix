{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.git-machete ];
  programs.git.settings.alias.m = "machete";
}
