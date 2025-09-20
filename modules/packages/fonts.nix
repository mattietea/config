{
  pkgs,
  ...
}:
{

  # https://home-manager-options.extranix.com/?query=fonts&release=master

  home.packages = with pkgs; [
    pkgs.nerd-fonts.geist-mono
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.meslo-lg
    pkgs.nerd-fonts.hack
  ];

  fonts = {
    fontconfig.enable = true;
  };
}
