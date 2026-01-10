{ lib }:
let
  ai = import ../../ai;
in
{
  # Transform MCP servers to opencode format
  # opencode uses: "remote" for remote, "local" for local
  mcpServers = lib.mapAttrs (
    _: cfg:
    if cfg.type == "remote" then
      {
        type = "remote";
        inherit (cfg) url;
      }
      // lib.optionalAttrs (cfg ? headers) { inherit (cfg) headers; }
    else
      {
        type = "local";
        inherit (cfg) command;
      }
      // lib.optionalAttrs (cfg ? environment) { inherit (cfg) environment; }
  ) ai.mcpServers;
}
