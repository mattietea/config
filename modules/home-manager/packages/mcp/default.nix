{
  pkgs,
  settings,
  ...
}:
{
  programs.mcp = {
    enable = true;
    servers = {
      context7 = {
        type = "stdio";
        command = "${pkgs.writeShellScript "context7-mcp" ''
          exec npx -y @upstash/context7-mcp --api-key "$(cat /run/agenix/context7-api-key)"
        ''}";
        args = [ ];
      };
      filesystem = {
        type = "stdio";
        command = "npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-filesystem"
          "/Users/${settings.username}"
        ];
      };
      grep = {
        type = "http";
        url = "https://mcp.grep.app";
      };
    };
  };
}
