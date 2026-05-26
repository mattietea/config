{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  codexPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
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
    package = codexPackage;
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
      hooks.state = {
        "${config.home.homeDirectory}/.codex/hooks.json:pre_tool_use:0:0".trusted_hash =
          "sha256:c9621198c46f5bc6032a626e91e1b89c84d3467b003c39db33ffd9ce764c7db0";
        "${config.home.homeDirectory}/.codex/hooks.json:permission_request:0:0".trusted_hash =
          "sha256:5ed3479622a78f4a7d42df5e73499499e3e427e8033abda59d7354f7561f4248";
        "${config.home.homeDirectory}/.codex/hooks.json:post_tool_use:0:0".trusted_hash =
          "sha256:83441ac77a145163f300d664df3b9f9a5039faf2e386e8f176752b11b2feab08";
        "${config.home.homeDirectory}/.codex/hooks.json:session_start:0:0".trusted_hash =
          "sha256:293270706daf9f175638efba6f4cd3e40c15b8c794ee99387b1419bd5485267f";
        "${config.home.homeDirectory}/.codex/hooks.json:user_prompt_submit:0:0".trusted_hash =
          "sha256:f6fa08a1ff537710d1cc37f2e90cd703542586423b88c8477cf548b786360ee1";
        "${config.home.homeDirectory}/.codex/hooks.json:stop:0:0".trusted_hash =
          "sha256:0a4be757d49d460b50264992495c1b2ddb1b4e8c0928cd47e3ce31543eff537c";
        "claude-mem@claude-mem-local:hooks/codex-hooks.json:pre_tool_use:0:0".trusted_hash =
          "sha256:be527484c3c5fb02c5bc846149f8d5e164918d2d5ea5d2c961a09037db8c4905";
        "claude-mem@claude-mem-local:hooks/codex-hooks.json:post_tool_use:0:0".trusted_hash =
          "sha256:a49c41be9e7dbc00e03703265adefdca46e12b77d722ca8b47fa0094db82f93b";
        "claude-mem@claude-mem-local:hooks/codex-hooks.json:session_start:0:0".trusted_hash =
          "sha256:84922f02a2c8ac9df62faaa0b63c38778360cd9900554bdec989108f796841ab";
        "claude-mem@claude-mem-local:hooks/codex-hooks.json:session_start:0:1".trusted_hash =
          "sha256:73009d71492f3db420bb856eb972da392e678eadcbc7e1e125e7430a67d49f4b";
        "claude-mem@claude-mem-local:hooks/codex-hooks.json:session_start:0:2".trusted_hash =
          "sha256:19949ab8aadd05443e67e1b66298d8e303b7c5a7150aae85114a04563e35d9c0";
        "claude-mem@claude-mem-local:hooks/codex-hooks.json:user_prompt_submit:0:0".trusted_hash =
          "sha256:c9ed4da2921325c632de9c9b4754dfd6edb753d8548f946a6073c4876507d44a";
        "claude-mem@claude-mem-local:hooks/codex-hooks.json:stop:0:0".trusted_hash =
          "sha256:1e99bde05721215c13722e100fd2ed6657dacffab6e1c5dcb9be47a56bf6f6d5";
      };
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
