_:
let
  baseConfig = import ../opencode/oh-my-opencode-base.nix;

  # Anthropic + OpenAI: enable hephaestus, use GPT-5.4 for Oracle/Momus per official docs
  config = baseConfig // {
    disabled_agents = [ ];
    agents = baseConfig.agents // {
      # Architecture & debugging (GPT-5.4 per official docs)
      oracle.model = "openai/gpt-5.4";
      # Review (GPT-5.4 per official docs)
      momus.model = "openai/gpt-5.4";
    };
    categories = {
      quick.model = "anthropic/claude-haiku-4-5";
      unspecified-low.model = "anthropic/claude-sonnet-4-5";
      unspecified-high.model = "openai/gpt-5.4";
      deep.model = "openai/gpt-5.3-codex";
      ultrabrain.model = "openai/gpt-5.3-codex";
    };
  };
in
{
  home.file.".config/opencode/oh-my-opencode.json".text = builtins.toJSON config;
}
