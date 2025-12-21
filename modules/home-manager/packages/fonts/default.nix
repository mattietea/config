{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    nerd-fonts.geist-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    nerd-fonts.hack
    nerd-fonts.iosevka
  ];

  fonts.fontconfig.enable = true;
}
