# Shared oh-my-openagent configuration
# Pure data file — imported by opencode-personal and opencode-work
# Base defaults are Anthropic-only; work host overrides with OpenAI where appropriate
let
  models = import ./models.nix;

  # Default profile for heavyweight agents: Opus with extended thinking,
  # Sonnet for fallback and compaction.
  opusAgent = {
    model = models.opus;
    thinking.type = "enabled";
    fallback_models = [ models.sonnet ];
    compaction.model = models.sonnet;
  };

  # Default profile for heavyweight categories.
  opusMax = {
    model = models.opus;
    variant = "max";
    thinking.type = "enabled";
  };
in
{
  model_fallback = true;

  browser_automation_engine = {
    provider = "agent-browser";
  };

  # Successor of the deprecated ralph_loop (which logged a warning on every
  # config read and got auto-migrated to this shape anyway).
  goal = {
    enabled = true;
    default_max_iterations = 100;
  };

  hashline_edit = true;

  runtime_fallback = {
    enabled = true;
    retry_on_errors = [
      400
      429
      503
      529
    ];
    max_fallback_attempts = 3;
    cooldown_seconds = 60;
    notify_on_fallback = true;
  };

  sisyphus_agent = {
    disabled = false;
    planner_enabled = true;
    replace_plan = true;
    default_builder_enabled = false;
  };

  team_mode = {
    enabled = true;
    # Schema caps both at 8 (values above fail validation, which silently
    # disables team_mode and the team_* tools entirely).
    max_parallel_members = 8;
    max_members = 8;
    tmux_visualization = false;
  };

  background_task = {
    providerConcurrency = {
      anthropic = 12;
    };
    modelConcurrency = {
      "${models.opus}" = 12;
    };
  };

  git_master = {
    commit_footer = false;
    include_co_authored_by = false;
  };

  notification = {
    force_enable = true;
  };

  experimental = {
    aggressive_truncation = true;
    dynamic_context_pruning = {
      enabled = true;
      notification = "minimal";
      turn_protection = {
        enabled = true;
        turns = 3;
      };
      strategies = {
        deduplication.enabled = true;
        supersede_writes = {
          enabled = true;
          aggressive = false;
        };
        purge_errors = {
          enabled = true;
          turns = 5;
        };
      };
    };
  };

  agents = {
    # Default opencode agent — fast interactive tier (no extended thinking)
    build = {
      model = models.sonnet;
      fallback_models = [ models.haiku ];
    };

    # Primary orchestrator
    sisyphus = opusAgent;

    sisyphus-junior.model = models.sonnet;

    # Plan execution orchestrator
    atlas.model = models.sonnet;

    # Planning & strategy
    prometheus = opusAgent;

    metis = opusAgent;

    # Review — host configs may override model + add thinking/reasoningEffort
    momus = opusAgent;

    # Architecture & debugging — host configs may override model + add thinking/reasoningEffort
    oracle = opusAgent;

    # Search & research — read-only, no edit/write permissions
    explore = {
      model = models.haiku;
      permission = {
        edit = "deny";
        webfetch = "allow";
      };
    };

    librarian = {
      model = models.haiku;
      permission = {
        edit = "deny";
        webfetch = "allow";
      };
    };

    # Visual analysis
    multimodal-looker.model = models.haiku;
  };

  # Category defaults (Anthropic); work host overrides deep/ultrabrain/unspecified-high with OpenAI
  categories = {
    quick.model = models.haiku;
    unspecified-low.model = models.sonnet;
    unspecified-high = opusMax;
    deep = opusMax;
    ultrabrain = opusMax;
    visual-engineering.model = models.sonnet;
    writing.model = models.sonnet;
    artistry.model = models.sonnet;
  };
}
