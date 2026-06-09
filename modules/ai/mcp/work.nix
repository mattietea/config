_: {
  # Work-only MCP servers
  programs.mcp.servers = {
    notion = {
      type = "remote";
      url = "https://mcp.notion.com/mcp";
    };
    incident-io = {
      type = "http";
      url = "https://mcp.incident.io/mcp";
    };
    # Remote server; client handles OAuth on first use (no API key needed).
    statsig = {
      type = "http";
      url = "https://api.statsig.com/v1/mcp";
    };
    chrome-devtools = {
      type = "stdio";
      command = "npx";
      args = [
        "-y"
        "chrome-devtools-mcp@latest"
      ];
    };
  };
}
