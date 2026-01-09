_: {

  programs.claude-code = {
    enable = true;
    settings = {
      mcpServers = {
        context7 = {
          url = "https://mcp.context7.com/mcp";
        };
      };
    };
  };
}
