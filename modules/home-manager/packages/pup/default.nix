{ pkgs, ... }:
{
  home.packages = [ pkgs.pup ];
  home.sessionVariables.DD_SITE = "us3.datadoghq.com";
}
