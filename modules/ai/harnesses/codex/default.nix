{
  config,
  pkgs,
  inputs,
  ...
}:
let
  upstreamCodex = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;

  # Wrap the codex binary so every invocation passes
  # --dangerously-bypass-hook-trust. This eliminates the manual SHA-256
  # `hooks.state.<...>.trusted_hash` table that would otherwise need a fresh
  # entry per hook command in every claude-mem (or orca) release.
  #
  # The flag bypasses Codex's hook-trust *verification*; it does NOT disable
  # hooks. Codex emits a startup banner on every session — accepted trade-off.
  # See: codex-rs/utils/cli/src/shared_options.rs ("DANGEROUS. Intended only
  # for automation that already vets hook sources.")
  #
  # Plugin/marketplace wiring for claude-mem lives in
  # ../../integrations/claude-mem.
  codexPackage = pkgs.symlinkJoin {
    name = "codex-bypass-hook-trust-${upstreamCodex.version or "unknown"}";
    paths = [ upstreamCodex ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/codex \
        --add-flags --dangerously-bypass-hook-trust
    '';
  };
in
{
  programs.codex = {
    enable = true;
    package = codexPackage;
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
}
