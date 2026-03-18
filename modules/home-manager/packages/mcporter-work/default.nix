_:
let
  baseServers = import ../mcporter/servers-base.nix;

  servers = baseServers // {
    datadog = {
      url = "https://mcp.us3.datadoghq.com/api/unstable/mcp-server/mcp";
      auth = "oauth";
    };
    slack = {
      url = "https://mcp.slack.com/mcp";
      auth = "oauth";
    };
  };
in
{
  home.file.".mcporter/mcporter.json".text = builtins.toJSON {
    "$schema" = "https://raw.githubusercontent.com/steipete/mcporter/main/mcporter.schema.json";
    mcpServers = servers;
  };
}
