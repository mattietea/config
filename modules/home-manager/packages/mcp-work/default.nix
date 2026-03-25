_: {
  imports = [ ../mcp ];

  # Work-only MCP servers
  programs.mcp.servers = {
    notion = {
      type = "remote";
      url = "https://mcp.notion.com/mcp";
    };
    datadog = {
      type = "remote";
      url = "https://mcp.us3.datadoghq.com/api/unstable/mcp-server/mcp";
    };
    linear = {
      type = "remote";
      url = "https://mcp.linear.app/mcp";
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
