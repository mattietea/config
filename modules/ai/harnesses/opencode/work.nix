_:
let
  models = import ../../models.nix;
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
        # gpt and gptStd currently resolve to the same id (no -pro variant
        # exists), so a single entry covers both.
        "${models.gpt}" = 12;
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
  # oh-my-openagent 5.x reads its unified config from ~/.omo/omo.jsonc (the
  # legacy ~/.config/opencode/oh-my-openagent.json is treated as a migration
  # source it can never delete out of the read-only nix store). Manage the
  # unified file directly, harness-scoped under "[opencode]", with the
  # migration marker so the plugin never re-runs the legacy migration.
  # force = true so home-manager re-establishes its symlink even after the
  # plugin atomically rewrites the file in place (renameSync), which would
  # otherwise leave a stale user-owned regular file at this path.
  home.file.".omo/omo.jsonc" = {
    force = true;
    text = builtins.toJSON {
      "$schema" =
        "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/omo.schema.json";
      "[opencode]" = config;
      # Mark plugin config migrations as applied — the plugin can't (and
      # mustn't) rewrite this read-only nix-managed file. When a new omo
      # version ships a new migration id, add it here and apply the shape
      # change to this config by hand.
      _migrations = [
        "2026-07-opencode-config-unification"
        "2026-08-reasoning-unification"
      ];
    };
  };

  programs.zsh.initContent = ''
    export ANTHROPIC_API_KEY="$(cat /run/agenix/anthropic-api-key)"
  '';
}
