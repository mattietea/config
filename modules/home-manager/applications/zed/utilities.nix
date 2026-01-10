{ lib }:
let
  ai = import ../../ai;
in
{
  # Transform MCP servers to Zed's context_servers format
  contextServers = lib.mapAttrs (
    _: cfg:
    if cfg.type == "remote" then
      { inherit (cfg) url; } // lib.optionalAttrs (cfg ? headers) { inherit (cfg) headers; }
    else
      {
        command = builtins.head cfg.command;
        args = builtins.tail cfg.command;
      }
      // lib.optionalAttrs (cfg ? environment) { env = cfg.environment; }
  ) ai.mcpServers;
}
