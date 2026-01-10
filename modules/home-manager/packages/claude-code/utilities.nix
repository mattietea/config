{ lib }:
let
  ai = import ../../ai;
in
{
  # Transform MCP servers to claude-code format
  # claude-code uses: "http" for remote, "stdio" for local
  mcpServers = lib.mapAttrs (
    _: cfg:
    if cfg.type == "remote" then
      {
        type = "http";
        inherit (cfg) url;
      }
      // lib.optionalAttrs (cfg ? headers) { inherit (cfg) headers; }
    else
      {
        type = "stdio";
        command = builtins.head cfg.command;
        args = builtins.tail cfg.command;
      }
      // lib.optionalAttrs (cfg ? environment) { env = cfg.environment; }
  ) ai.mcpServers;
}
