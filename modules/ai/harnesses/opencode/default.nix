{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.opencode = {
    enable = true;
    package = llm-agents.opencode;
    enableMcpIntegration = true;
    settings = {
      "$schema" = "https://opencode.ai/config.json";
      share = "disabled";
      snapshot = true;
      compaction = {
        auto = true;
        prune = true;
      };
      plugin = [
        "oh-my-openagent"
      ];
    };
    tui = {
      theme = "system";
    };
  };

  # Clean stale opencode runtime state on each activation.
  # model.json holds a remembered model picker that can reference old/invalid models.
  # The plugin creates .bak.* and .migrations.json files when it tries (and fails)
  # to rewrite the nix-managed read-only symlink.
  # The oh-my-openagent@latest cache pins to whatever was first fetched and never
  # updates — wipe it so each switch picks up the current npm release.
  home.activation.cleanOpencodeState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -f "$HOME/.local/state/opencode/model.json"
    rm -f "$HOME/.config/opencode/oh-my-openagent.json.bak."*
    rm -f "$HOME/.config/opencode/oh-my-openagent.json.migrations.json"
    rm -rf "$HOME/.cache/opencode/packages/oh-my-openagent@latest"
  '';

  # Install the claude-mem opencode plugin if it is missing. The MCP server
  # is registered declaratively in modules/ai/mcp/default.nix; this hook
  # provides the matching session/tool capture plugin so opencode also
  # writes to the shared ~/.claude-mem/claude-mem.db that claude-code uses.
  #
  # The installer copies a JS bundle from the npm package's prebuilt dist/
  # to ~/.config/opencode/plugins/claude-mem.js. It also tries to inject a
  # placeholder into ~/.config/opencode/AGENTS.md, which fails silently here
  # because that path is owned by the instructions module — the plugin still
  # captures sessions, but auto-injected memory context is not surfaced in
  # AGENTS.md (query memory via the claude-mem MCP tools instead).
  home.activation.installClaudeMemOpencodePlugin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.config/opencode/plugins/claude-mem.js" ]; then
      echo "Installing claude-mem opencode plugin..."
      ${pkgs.nodejs}/bin/npx -y claude-mem install --ide opencode \
        || echo "WARNING: claude-mem opencode install failed — run \`npx claude-mem install --ide opencode\` manually"
    fi
  '';
}
