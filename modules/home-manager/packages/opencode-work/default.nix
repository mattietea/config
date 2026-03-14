_:
let
  baseConfig = import ../opencode/oh-my-opencode-base.nix;

  # Anthropic + OpenAI: GPT-5.4 for oracle/momus, GPT-5.3-codex for deep work, hephaestus enabled
  config = baseConfig // {
    disabled_agents = [ ];
    agents = baseConfig.agents // {
      # Architecture & debugging — GPT-5.4 with high reasoning effort
      oracle = {
        model = "openai/gpt-5.4";
        variant = "high";
        reasoningEffort = "high";
      };
      # Review — GPT-5.4 with high reasoning effort
      momus = {
        model = "openai/gpt-5.4";
        variant = "high";
      };
      # Autonomous deep worker — GPT-5.3-codex
      hephaestus = {
        model = "openai/gpt-5.3-codex";
        variant = "medium";
      };
    };
    background_task = baseConfig.background_task // {
      providerConcurrency = baseConfig.background_task.providerConcurrency // {
        openai = 5;
      };
    };
    categories = baseConfig.categories // {
      deep = {
        model = "openai/gpt-5.3-codex";
        variant = "medium";
      };
      ultrabrain = {
        model = "openai/gpt-5.4";
        variant = "xhigh";
        reasoningEffort = "xhigh";
      };
      unspecified-high = {
        model = "openai/gpt-5.4";
        variant = "high";
      };
    };
  };
in
{
  home.file.".config/opencode/oh-my-opencode.json".text = builtins.toJSON config;
}
