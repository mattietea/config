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
    slack = {
      type = "remote";
      url = "https://mcp.slack.com/mcp";
      oauth = {
        clientId = "1601185624273.8899143856786";
        callbackPort = 3118;
      };
    };
  };
}
