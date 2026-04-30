_:
let
  baseConfig = import ./oh-my-openagent-base.nix;

  # Anthropic + OpenAI: GPT-5.5 for oracle/momus, GPT-5.3-codex for deep work, hephaestus enabled
  config = baseConfig // {
    disabled_agents = [ ];
    agents = baseConfig.agents // {
      # Architecture & debugging — GPT-5.4 with high reasoning effort
      oracle = {
        model = "openai/gpt-5.5";
        variant = "high";
        reasoningEffort = "high";
        fallback_models = [
          "anthropic/claude-opus-4-7"
          "anthropic/claude-sonnet-4-6"
        ];
        compaction.model = "anthropic/claude-sonnet-4-6";
      };
      # Review — GPT-5.4 with high reasoning effort
      momus = {
        model = "openai/gpt-5.5";
        variant = "high";
        fallback_models = [
          "anthropic/claude-opus-4-7"
          "anthropic/claude-sonnet-4-6"
        ];
        compaction.model = "anthropic/claude-sonnet-4-6";
      };
      # Autonomous deep worker — GPT-5.3-codex
      hephaestus = {
        model = "openai/gpt-5.3-codex";
        variant = "medium";
        fallback_models = [
          "anthropic/claude-sonnet-4-6"
        ];
      };
      # Fast utility runners — pin to claude-sonnet-4-6 (override base haiku/plugin gpt defaults)
      explore = baseConfig.agents.explore // {
        model = "anthropic/claude-sonnet-4-6";
      };
      librarian = baseConfig.agents.librarian // {
        model = "anthropic/claude-sonnet-4-6";
      };
      multimodal-looker.model = "anthropic/claude-sonnet-4-6";
    };
    background_task = baseConfig.background_task // {
      providerConcurrency = baseConfig.background_task.providerConcurrency // {
        openai = 5;
      };
      modelConcurrency = baseConfig.background_task.modelConcurrency // {
        "openai/gpt-5.5" = 3;
        "openai/gpt-5.3-codex" = 3;
      };
    };
    categories = baseConfig.categories // {
      quick.model = "anthropic/claude-sonnet-4-6";
      deep = {
        model = "openai/gpt-5.3-codex";
        variant = "medium";
      };
      ultrabrain = {
        model = "openai/gpt-5.5";
        variant = "xhigh";
        reasoningEffort = "xhigh";
      };
      unspecified-high = {
        model = "openai/gpt-5.5";
        variant = "high";
      };
    };
  };
in
{
  home.file.".config/opencode/oh-my-openagent.json".text = builtins.toJSON config;

  programs.zsh.initContent = ''
    export ANTHROPIC_API_KEY="$(cat /run/agenix/anthropic-api-key)"
  '';
}
