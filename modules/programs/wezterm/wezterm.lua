local wezterm = require 'wezterm'
local config = {}

config.font = wezterm.font 'SFMono Nerd Font'
config.front_end = 'WebGpu'
config.color_schemes = 'tokyonight';

config.skip_close_confirmation_for_processes_named = true;
config.window_close_confirmation = true;

return config
