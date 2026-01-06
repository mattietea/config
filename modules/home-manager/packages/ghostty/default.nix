{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    enableZshIntegration = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 14;
      theme = "light:GitHub Light,dark:GitHub Dark";
      window-decoration = "auto";
      macos-titlebar-style = "tabs";
    };
  };
}
