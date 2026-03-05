_: {
  # Work-only MCP servers
  programs.mcp.servers = {
    notion = {
      type = "http";
      url = "https://mcp.notion.com/mcp";
    };
    datadog = {
      type = "http";
      url = "https://mcp.us3.datadoghq.com/api/unstable/mcp-server/mcp";
    };
  };
}
