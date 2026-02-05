{
  pkgs,
  ...
}:
{
  programs.mcp = {
    enable = true;
    servers = {
      context7 = {
        type = "stdio";
        command = "npx";
        args = [
          "-y"
          "@upstash/context7-mcp"
        ];
      };
      filesystem = {
        type = "stdio";
        command = "npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-filesystem"
          "/Users/mattietea"
        ];
      };
    };
  };
}
