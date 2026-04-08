{
  pkgs,
  settings,
  ...
}:
{
  programs.mcp = {
    enable = true;
    servers = {
      filesystem = {
        type = "stdio";
        command = "npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-filesystem"
          "/Users/${settings.username}"
        ];
      };
      exa = {
        type = "stdio";
        command = "${pkgs.writeShellScript "exa-mcp" ''
          export EXA_API_KEY="$(cat /run/agenix/exa-api-key)"
          exec npx -y exa-mcp-server
        ''}";
        args = [ ];
      };
      grep = {
        type = "http";
        url = "https://mcp.grep.app";
      };
    };
  };
}
