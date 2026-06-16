_:
let
  models = import ./models.nix;
  baseConfig = import ./oh-my-openagent-base.nix;

  # Anthropic + OpenAI: base default agents stay on Opus, GPT for oracle/momus,
  # hephaestus, and deep work
  config = baseConfig // {
    disabled_agents = [ ];
    agents = baseConfig.agents // {
      # Architecture & debugging — GPT with high reasoning effort
      oracle = {
        model = models.gpt;
        variant = "high";
        reasoningEffort = "high";
        fallback_models = [
          models.opus
          models.sonnet
        ];
        compaction.model = models.sonnet;
      };
      # Review — GPT with high reasoning effort
      momus = {
        model = models.gpt;
        variant = "high";
        fallback_models = [
          models.opus
          models.sonnet
        ];
        compaction.model = models.sonnet;
      };
      # Autonomous deep worker — GPT
      hephaestus = {
        model = models.gpt;
        variant = "xhigh";
        fallback_models = [
          models.sonnet
        ];
      };
      # Fast utility runners — pin to Sonnet (override base haiku/plugin gpt defaults)
      explore = baseConfig.agents.explore // {
        model = models.sonnet;
      };
      librarian = baseConfig.agents.librarian // {
        model = models.sonnet;
      };
      multimodal-looker.model = models.sonnet;
    };
    background_task = baseConfig.background_task // {
      providerConcurrency = baseConfig.background_task.providerConcurrency // {
        openai = 5;
      };
      modelConcurrency = baseConfig.background_task.modelConcurrency // {
        "${models.gpt}" = 3;
      };
    };
    categories = baseConfig.categories // {
      quick.model = models.sonnet;
      deep = {
        model = models.gpt;
        variant = "xhigh";
      };
      ultrabrain = {
        model = models.gpt;
        variant = "xhigh";
        reasoningEffort = "xhigh";
      };
      unspecified-high = {
        model = models.gpt;
        variant = "high";
      };
    };
  };
in
{
  # force = true so home-manager re-establishes its symlink even after the
  # opencode plugin atomically rewrites the file in place (renameSync), which
  # would otherwise leave a stale user-owned regular file with drifted values
  # (notably git_master.include_co_authored_by) at this path.
  home.file.".config/opencode/oh-my-openagent.json" = {
    force = true;
    text = builtins.toJSON config;
  };

  programs.zsh.initContent = ''
    export ANTHROPIC_API_KEY="$(cat /run/agenix/anthropic-api-key)"
  '';
}
