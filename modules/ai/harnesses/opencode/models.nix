# Single source of truth for model ids used across the opencode configs
# (oh-my-openagent-base.nix + per-host overrides). Bump a model here and
# every agent/category referencing it follows.
{
  opus = "anthropic/claude-opus-4-8";
  sonnet = "anthropic/claude-sonnet-4-6";
  haiku = "anthropic/claude-haiku-4-5";
  gpt = "openai/gpt-5.5";
  codex = "openai/gpt-5.3-codex";
}
