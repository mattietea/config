{
  pkgs,
  inputs,
  ...
}:
{
  programs.codex = {
    enable = true;
    # Use the pre-built codex from llm-agents.nix (numtide) so we hit
    # cache.numtide.com instead of building from source against nixpkgs.
    # Mirrors how opencode is wired in ../opencode/default.nix.
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
    enableMcpIntegration = true;
    settings = {
      approval_policy = "never";
      model = "gpt-5.5";
      model_reasoning_effort = "high";
      sandbox_mode = "danger-full-access";
    };
  };
}
