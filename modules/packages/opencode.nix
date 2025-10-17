{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.pkgs.opencode;
in
{
  options.pkgs.opencode.enable = mkEnableOption "opencode";

  config = mkIf cfg.enable {
    programs.opencode = {
      enable = true;

      settings = {
        autoshare = false;
        mcp = {
          "context7" = {
            type = "remote";
            url = "https://mcp.context7.com/mcp";
          };
        };
      };

    };
  };
}
