{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.delta;
in
{
  options.pkgs.delta.enable = mkEnableOption "delta (git diff pager)";

  config = mkIf cfg.enable {
    programs.git.delta = {
      enable = true;
      package = pkgs.delta;
      options = {
        hyperlinks = true;
        side-by-side = true;
        hyperlinks-file-link-format = "zed://file/{path}:{line}";
      };
    };
  };
}
