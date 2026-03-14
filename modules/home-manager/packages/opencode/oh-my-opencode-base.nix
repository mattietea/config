# Shared oh-my-opencode configuration
# Pure data file — imported by opencode-personal and opencode-work
# Base defaults are Anthropic-only; work host overrides with OpenAI where appropriate
{
  "$schema" =
    "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json";

  google_auth = false;

  ralph_loop = {
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

  background_task = {
    providerConcurrency = {
      anthropic = 3;
    };
    modelConcurrency = {
      "anthropic/claude-opus-4-6" = 2;
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
    # Primary orchestrator
    Sisyphus = {
      model = "anthropic/claude-opus-4-6";
      thinking = {
        type = "enabled";
        budgetTokens = 32000;
      };
    };

    sisyphus-junior.model = "anthropic/claude-sonnet-4-5";

    # Plan execution orchestrator
    atlas.model = "anthropic/claude-sonnet-4-5";

    # Planning & strategy
    prometheus = {
      model = "anthropic/claude-opus-4-6";
      thinking = {
        type = "enabled";
        budgetTokens = 32000;
      };
    };

    metis = {
      model = "anthropic/claude-opus-4-6";
      thinking = {
        type = "enabled";
        budgetTokens = 32000;
      };
    };

    # Review — host configs may override model + add thinking/reasoningEffort
    momus.model = "anthropic/claude-opus-4-6";

    # Architecture & debugging — host configs may override model + add thinking/reasoningEffort
    oracle.model = "anthropic/claude-opus-4-6";

    # Search & research — read-only, no edit/write permissions
    explore = {
      model = "anthropic/claude-haiku-4-5";
      permission = {
        edit = "deny";
        webfetch = "allow";
      };
    };

    librarian = {
      model = "anthropic/claude-sonnet-4-5";
      permission = {
        edit = "deny";
        webfetch = "allow";
      };
    };

    # Visual analysis
    multimodal-looker.model = "anthropic/claude-haiku-4-5";
  };

  # Category defaults (Anthropic); work host overrides deep/ultrabrain/unspecified-high with OpenAI
  categories = {
    quick.model = "anthropic/claude-haiku-4-5";
    unspecified-low.model = "anthropic/claude-sonnet-4-5";
    unspecified-high = {
      model = "anthropic/claude-opus-4-6";
      variant = "max";
    };
    deep = {
      model = "anthropic/claude-opus-4-6";
      variant = "max";
    };
    ultrabrain = {
      model = "anthropic/claude-opus-4-6";
      variant = "max";
    };
    visual-engineering.model = "anthropic/claude-sonnet-4-5";
    writing.model = "anthropic/claude-sonnet-4-5";
    artistry.model = "anthropic/claude-sonnet-4-5";
  };
}
