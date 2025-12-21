_: {
  programs.opencode = {
    enable = true;

    settings = {
      autoshare = false;
      mcp = {
        "context7" = {
          type = "remote";
          url = "https://mcp.context7.com/mcp";
        };
      };
    };
  };
}
