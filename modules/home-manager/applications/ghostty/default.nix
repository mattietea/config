{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    enableZshIntegration = false;
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

  # Source Ghostty shell integration manually to support both Ghostty and cmux.
  # cmux sets GHOSTTY_RESOURCES_DIR to .../Resources/ghostty but places
  # shell-integration files at .../Resources/shell-integration/ instead.
  programs.zsh.initContent = ''
    if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
      source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration 2>/dev/null || \
        source "''${GHOSTTY_RESOURCES_DIR%/ghostty}"/shell-integration/ghostty-integration.zsh 2>/dev/null
    fi
  '';
}
