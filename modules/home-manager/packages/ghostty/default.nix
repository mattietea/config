{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    enableZshIntegration = true;
    settings = {
      font-family = "JetBrainsMono NFM Bold";
      font-size = 14;
      font-thicken = true;
      font-thicken-strength = 255;
      theme = "light:GitHub Light High Contrast,dark:GitHub Dark High Contrast";
      window-decoration = "auto";
      macos-titlebar-style = "tabs";
      window-padding-x = 4;
      window-padding-y = 4;
      macos-option-as-alt = true;
      confirm-close-surface = false;
      bold-is-bright = true;
    };
  };
}
