_:
let
  baseConfig = import ./oh-my-openagent-base.nix;

  # Anthropic-only: disable hephaestus, add adaptive thinking for oracle/momus
  config = baseConfig // {
    disabled_agents = [ "hephaestus" ];
    agents = baseConfig.agents // {
      oracle = {
        model = "anthropic/claude-opus-4-7";
        thinking.type = "adaptive";
        fallback_models = [
          "anthropic/claude-sonnet-4-6"
        ];
        compaction.model = "anthropic/claude-sonnet-4-6";
      };
      momus = {
        model = "anthropic/claude-opus-4-7";
        thinking.type = "adaptive";
        fallback_models = [
          "anthropic/claude-sonnet-4-6"
        ];
        compaction.model = "anthropic/claude-sonnet-4-6";
      };
    };
  };
in
{
  home.file.".config/opencode/oh-my-openagent.json".text = builtins.toJSON config;

  programs.opencode.settings.plugin = [
    "opencode-with-claude"
  ];
}
