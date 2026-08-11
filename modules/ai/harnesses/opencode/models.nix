# Single source of truth for model ids used across the AI harness configs
# (oh-my-openagent-base.nix + per-host overrides, omp roles). Bump a model
# here and every agent/category/role referencing it follows.
{
  fable = "anthropic/claude-fable-5";
  opus = "anthropic/claude-opus-4-8";
  sonnet = "anthropic/claude-sonnet-5";
  haiku = "anthropic/claude-haiku-4-5";
  gpt = "openai/gpt-5.6-sol"; # no -pro variant exists in the provider — deep, ultrabrain run sol at high/xhigh
  gptStd = "openai/gpt-5.6-sol"; # faster non-pro — oracle, momus, hephaestus, unspecified-high
}
