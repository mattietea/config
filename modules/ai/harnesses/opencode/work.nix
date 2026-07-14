_:
let
  models = import ./models.nix;
  baseConfig = import ./oh-my-openagent-base.nix;

  # Heavyweight Anthropic agents run on Fable 5 (work org has the required 30-day
  # data retention); fall back to Opus then Sonnet on refusal/error.
  fableAgent = {
    model = models.fable;
    variant = "max";
    thinking.type = "enabled";
    fallback_models = [
      models.opus
      models.sonnet
    ];
    compaction.model = models.sonnet;
  };

  # Anthropic + OpenAI: Fable for the default/orchestrator/planning agents,
  # GPT for oracle/momus, hephaestus, and deep work
  config = baseConfig // {
    disabled_agents = [ ];
    agents = baseConfig.agents // {
      # Orchestrator and planning agents — Fable 5 (override base Opus).
      # build inherits the fast base default (Sonnet, no thinking).
      sisyphus = fableAgent;
      prometheus = fableAgent;
      metis = fableAgent;
      # Architecture & debugging — Sol (non-pro) at high reasoning effort
      oracle = {
        model = models.gptStd;
        variant = "high";
        reasoningEffort = "high";
        fallback_models = [
          models.opus
          models.sonnet
        ];
        compaction.model = models.sonnet;
      };
      # Review — Sol (non-pro) at high reasoning effort
      momus = {
        model = models.gptStd;
        variant = "high";
        fallback_models = [
          models.opus
          models.sonnet
        ];
        compaction.model = models.sonnet;
      };
      # Autonomous deep worker — Sol (non-pro) at medium (author default)
      hephaestus = {
        model = models.gptStd;
        variant = "medium";
        fallback_models = [
          models.sonnet
        ];
      };
      # explore / librarian / multimodal-looker inherit the fast base (Haiku)
    };
    background_task = baseConfig.background_task // {
      providerConcurrency = baseConfig.background_task.providerConcurrency // {
        openai = 12;
      };
      modelConcurrency = baseConfig.background_task.modelConcurrency // {
        "${models.fable}" = 12;
        "${models.gpt}" = 12;
        "${models.gptStd}" = 12;
      };
    };
    categories = baseConfig.categories // {
      # quick inherits base Haiku
      deep = {
        model = models.gpt;
        variant = "high";
      };
      ultrabrain = {
        model = models.gpt;
        variant = "xhigh";
        reasoningEffort = "xhigh";
      };
      unspecified-high = {
        model = models.gptStd;
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
