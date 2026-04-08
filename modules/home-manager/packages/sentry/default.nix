{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.sentry-cli ];
  home.shellAliases.sentry = "${pkgs.sentry-cli}/bin/sentry-cli";
}
