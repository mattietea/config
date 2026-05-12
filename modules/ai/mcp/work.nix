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
