{
  pkgs,
  inputs,
  ...
}:
let
  llm-agents = inputs.llm-agents.packages.${pkgs.system};
in
{
  programs.opencode = {
    enable = true;
    package = llm-agents.opencode;
    enableMcpIntegration = true;
    settings = {
      "$schema" = "https://opencode.ai/config.json";
      share = "disabled";
      snapshot = true;
      compaction = {
        auto = true;
        prune = true;
      };
      plugin = [
        "oh-my-openagent"
        "opencode-with-claude"
        "@tarquinen/opencode-dcp"
      ];
      provider = {
        anthropic = {
          options = {
            baseURL = "http://127.0.0.1:3456";
            apiKey = "dummy";
          };
        };
      };
    };
  };
}
