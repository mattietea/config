{
  pkgs,
  inputs,
  ...
}:
let
  llm-agents = inputs.llm-agents.packages.${pkgs.system};
in
{
  home.packages = [ llm-agents.oh-my-opencode ];

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
        "opencode-claude-auth"
      ];
    };
  };
}
