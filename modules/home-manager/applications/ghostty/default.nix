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
      adjust-cursor-thickness = 3;
      theme = "light:GitHub,dark:GitHub Dark High Contrast";
      window-decoration = "auto";
      macos-titlebar-style = "tabs";
      window-padding-x = 8;
      window-padding-y = 4;
      macos-option-as-alt = true;
      confirm-close-surface = false;
      bold-is-bright = true;
      unfocused-split-opacity = 0.95;
    };
  };
}
