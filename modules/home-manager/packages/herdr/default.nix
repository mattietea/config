{
  pkgs,
  ...
}:
let
  tomlFormat = pkgs.formats.toml { };
in
{
  home.packages = [ pkgs.herdr ];

  xdg.configFile."herdr/config.toml".source = tomlFormat.generate "herdr-config.toml" {
    onboarding = false;

    # ANSI palettes can retain near-white text in light mode.
    theme = {
      name = "terminal";
      auto_switch = true;
      light_name = "catppuccin-latte";
      dark_name = "terminal";
    };
  };
}
