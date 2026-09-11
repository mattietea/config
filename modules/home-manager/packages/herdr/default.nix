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
    # "terminal" inherits ghostty's palette, which already switches GitHub
    # light/dark with system appearance.
    theme.name = "terminal";
  };
}
