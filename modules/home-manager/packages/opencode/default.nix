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
      autoshare = false;
      plugin = [
        "oh-my-opencode"
        "opencode-claude-auth"
      ];
    };
  };
}
