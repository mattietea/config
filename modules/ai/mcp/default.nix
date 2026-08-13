# Base MCP config is just the enable switch; servers are host-specific
# (work adds its set in ./work.nix).
_: {
  programs.mcp.enable = true;
}
