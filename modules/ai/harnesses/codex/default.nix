{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  claudeMemManifest = builtins.fromJSON (
    builtins.readFile "${inputs.claude-mem}/.codex-plugin/plugin.json"
  );
in
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
      features.plugin_hooks = true;
      marketplaces.claude-mem-local = {
        source_type = "local";
        source = "${inputs.claude-mem}";
      };
      plugins."claude-mem@claude-mem-local".enabled = true;
      projects."${config.home.homeDirectory}/.config/nix".trust_level = "trusted";
    };
  };

  home.activation.installCodexClaudeMemPluginCache = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    target="$HOME/.codex/plugins/cache/claude-mem-local/claude-mem/${claudeMemManifest.version}"
    rm -rf "$target"
    mkdir -p "$(dirname "$target")"
    cp -R "${inputs.claude-mem}/plugin" "$target"
    chmod -R u+w "$target"
  '';
}
