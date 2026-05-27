{
  config,
  pkgs,
  inputs,
  ...
}:
{
  programs.codex = {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
    enableMcpIntegration = true;
    settings = {
      approval_policy = "never";
      model = "gpt-5.5";
      model_reasoning_effort = "high";
      sandbox_mode = "danger-full-access";
      features.hooks = true;
      projects."${config.home.homeDirectory}/.config/nix".trust_level = "trusted";
    };
  };

  # Bypass Codex's hook-trust verification on every interactive `codex`
  # invocation. Mirrors the `claude` alias pattern. Non-interactive codex
  # invocations (e.g. `codex exec` from a script) won't get the flag and may
  # hit trust prompts. Plugin/marketplace wiring for claude-mem lives in
  # ../../integrations/claude-mem.
  programs.zsh.shellAliases.codex = "codex --dangerously-bypass-hook-trust";
}
