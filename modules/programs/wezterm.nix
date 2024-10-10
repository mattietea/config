{...}:

{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        font = wezterm.font 'SFMono Nerd Font'
        color_scheme = 'Github Dark'
        font_size = 18
        config.front_end = "WebGpu"
      }
    '';
  };
}
