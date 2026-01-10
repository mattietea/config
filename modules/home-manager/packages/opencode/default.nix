{ inputs, pkgs, ... }:
{
  programs.opencode = {
    enable = true;
    package = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;
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
}
