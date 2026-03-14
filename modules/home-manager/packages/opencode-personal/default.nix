_:
let
  baseConfig = import ../opencode/oh-my-opencode-base.nix;

  # Anthropic-only: disable hephaestus, add extended thinking for oracle/momus
  config = baseConfig // {
    disabled_agents = [ "hephaestus" ];
    agents = baseConfig.agents // {
      oracle = {
        model = "anthropic/claude-opus-4-6";
        thinking = {
          type = "enabled";
          budgetTokens = 200000;
        };
      };
      momus = {
        model = "anthropic/claude-opus-4-6";
        thinking = {
          type = "enabled";
          budgetTokens = 32000;
        };
      };
    };
  };
in
{
  home.file.".config/opencode/oh-my-opencode.json".text = builtins.toJSON config;
}
