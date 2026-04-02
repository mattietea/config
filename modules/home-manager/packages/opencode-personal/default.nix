_:
let
  baseConfig = import ../opencode/oh-my-opencode-base.nix;

  # Anthropic-only: disable hephaestus, add adaptive thinking for oracle/momus
  config = baseConfig // {
    disabled_agents = [ "hephaestus" ];
    agents = baseConfig.agents // {
      oracle = {
        model = "anthropic/claude-opus-4-6";
        thinking.type = "adaptive";
        fallback_models = [
          "anthropic/claude-sonnet-4-6"
        ];
        compaction.model = "anthropic/claude-haiku-4-5";
      };
      momus = {
        model = "anthropic/claude-opus-4-6";
        thinking.type = "adaptive";
        fallback_models = [
          "anthropic/claude-sonnet-4-6"
        ];
        compaction.model = "anthropic/claude-haiku-4-5";
      };
    };
  };
in
{
  imports = [ ../opencode ];

  programs.opencode.settings.plugin = [ "opencode-claude-auth" ];

  home.file.".config/opencode/oh-my-opencode.json".text = builtins.toJSON config;
}
