{
  lib,
  ...
}:
{
  # Work host runs Claude Fable 5 (Anthropic's most capable model); the work org
  # has the required 30-day data retention enabled. Personal stays on opus[1m]
  # via the shared base. No [1m] suffix — Fable's context window is 1M by default.
  programs.claude-code.settings.model = lib.mkForce "fable";
}
