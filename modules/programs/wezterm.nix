{...}:

{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        font = wezterm.font 'SFMono Nerd Font'
        color_scheme = 'Tokyo Night'
        font_size = 18
        config.front_end = "WebGpu"
      }
    '';
  };
}
