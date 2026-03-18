_:
let
  # Import service configs from co-located mcp/ directories
  linear = import ../mcp/linear/mcp.nix;
  notion = import ../mcp/notion/mcp.nix;
  datadog = import ../mcp/datadog/mcp.nix;
  slack = import ../mcp/slack/mcp.nix;
in
{
  programs = {
    # Direct MCP access — always loaded into context
    # Used for services where mcporter OAuth is blocked (redirect_uri mismatch)
    mcp.servers = {
      datadog = {
        type = "remote";
        inherit (datadog) url;
      };
      slack = {
        type = "remote";
        inherit (slack) url oauth;
      };
    };

    # Agent skills — discovered from co-located SKILL.md files
    agent-skills.sources.services = {
      path = ../mcp;
      filter.nameRegex = "^(linear|notion|datadog|slack)$";
    };
    agent-skills.skills.enable = [
      "linear"
      "notion"
      "datadog"
      "slack"
    ];
  };

  # mcporter config — on-demand access via skills, saves context
  home.file.".mcporter/mcporter.json".text = builtins.toJSON {
    "$schema" = "https://raw.githubusercontent.com/steipete/mcporter/main/mcporter.schema.json";
    mcpServers = {
      linear = {
        inherit (linear) url;
        auth = "oauth";
      };
      notion = {
        inherit (notion) url;
        auth = "oauth";
      };
      datadog = {
        inherit (datadog) url;
        auth = "oauth";
      };
      slack = {
        inherit (slack) url;
        auth = "oauth";
      };
    };
  };

}
