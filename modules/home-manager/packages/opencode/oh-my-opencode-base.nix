# Shared oh-my-opencode configuration
# Pure data file — imported by opencode-personal and opencode-work
{
  "$schema" =
    "https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json";
  google_auth = false;
  ralph_loop = {
    enabled = true;
    default_max_iterations = 100;
  };
  agents = {
    # Primary orchestrator (Opus per official docs)
    Sisyphus.model = "anthropic/claude-opus-4-6";
    sisyphus-junior.model = "anthropic/claude-sonnet-4-5";

    # Plan execution orchestrator (Sonnet per official docs)
    atlas.model = "anthropic/claude-sonnet-4-5";

    # Planning & strategy (Opus per official docs)
    prometheus.model = "anthropic/claude-opus-4-6";
    metis.model = "anthropic/claude-opus-4-6";

    # Review (Opus fallback for Anthropic-only setups)
    momus.model = "anthropic/claude-opus-4-6";

    # Architecture & debugging (Opus fallback for Anthropic-only setups)
    oracle.model = "anthropic/claude-opus-4-6";

    # Search & research
    explore.model = "anthropic/claude-haiku-4-5";
    librarian.model = "anthropic/claude-sonnet-4-5";

    # Specialized agents
    frontend-ui-ux-engineer.model = "anthropic/claude-sonnet-4-5";
    document-writer.model = "anthropic/claude-sonnet-4-5";
    multimodal-looker.model = "anthropic/claude-haiku-4-5";
    qa-tester.model = "anthropic/claude-sonnet-4-5";
  };
}
