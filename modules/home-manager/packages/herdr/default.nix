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
    # The config file is a read-only nix symlink; the first-run wizard would
    # try to write to it.
    session.onboarding = false;
  };
}
