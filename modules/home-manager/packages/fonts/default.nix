{
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.enable = true;
}
