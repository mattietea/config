{
  pkgs,
  ...
}:
{

  # https://home-manager-options.extranix.com/?query=fonts&release=master

  home.packages = with pkgs; [
    nerdfonts
    powerline-fonts
  ];

  fonts = {
    fontconfig.enable = true;
  };
}
