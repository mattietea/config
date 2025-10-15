{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.tldr;
in
{
  options.pkgs.tldr.enable = mkEnableOption "tldr";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.tldr ];
  };
}
