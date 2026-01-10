# Shared AI configuration
# Import what you need: (import ../ai).mcpServers
{
  mcpServers = import ./mcp.nix;
  rules = import ./rules.nix;
  agents = import ./agents.nix;
}
