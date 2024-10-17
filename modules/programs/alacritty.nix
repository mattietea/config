{ ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {

      live_config_reload = true;

      font = {
        size = 20;
        normal = {
          family = "SFMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "SFMono Nerd Font";
          style = "Medium";
        };
        italic = {
          family = "SFMono Nerd Font";
          style = "Italic";
        };
        bold_italic = {
          family = "SFMono Nerd Font";
          style = "Medium Italic";
        };
      };

      env = {
        TERM = "xterm-256color";
      };

      colors = {
        primary = {
          background = "#0d1117";
          foreground = "#e6edf3";
        };
        normal = {
          black = "#484f58";
          red = "#ff7b72";
          green = "#3fb950";
          yellow = "#d29922";
          blue = "#58a6ff";
          magenta = "#bc8cff";
          cyan = "#39c5cf";
          white = "#b1bac4";
        };
        bright = {
          black = "#6e7681";
          red = "#ffa198";
          green = "#56d364";
          yellow = "#e3b341";
          blue = "#79c0ff";
          magenta = "#d2a8ff";
          cyan = "#56d4dd";
          white = "#f0f6fc";
        };
        indexed_colors = [
          {
            index = 16;
            color = "#d18616";
          }
          {
            index = 17;
            color = "#ffa198";
          }
        ];
      };
    };
  };
}
