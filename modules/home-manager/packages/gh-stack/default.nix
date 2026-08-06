{ pkgs, ... }:
{
  programs.gh.extensions = [ pkgs.gh-stack ];
}
