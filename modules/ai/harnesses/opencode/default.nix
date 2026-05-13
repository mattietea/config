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
  home.activation = {
    cleanOpencodeState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      rm -f "$HOME/.local/state/opencode/model.json"
      rm -f "$HOME/.config/opencode/oh-my-openagent.json.bak."*
      rm -f "$HOME/.config/opencode/oh-my-openagent.json.migrations.json"
      rm -rf "$HOME/.cache/opencode/packages/oh-my-openagent@latest"
    '';

    # Orca launches opencode with OPENCODE_CONFIG_DIR pointed at its hook
    # directory so its status plugin can be injected. oh-my-openagent also reads
    # its config from OPENCODE_CONFIG_DIR, so mirror the nix-managed config into
    # each Orca hook dir instead of letting it fall back to plugin defaults.
    linkOhMyOpenagentOrcaHookConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ORCA_HOOKS_DIR="$HOME/Library/Application Support/orca/opencode-hooks"

      if [ -d "$ORCA_HOOKS_DIR" ]; then
        for hook_dir in "$ORCA_HOOKS_DIR"/*; do
          if [ -d "$hook_dir" ]; then
            ln -sf "$HOME/.config/opencode/oh-my-openagent.json" "$hook_dir/oh-my-openagent.json"
          fi
        done
      fi
    '';

    # Install the claude-mem opencode plugin if it is missing. The MCP server
    # is registered declaratively in modules/ai/mcp/default.nix; this hook
    # provides the matching session/tool capture plugin so opencode also
    # writes to the shared ~/.claude-mem/claude-mem.db that claude-code uses.
    #
    # The upstream `npx claude-mem install --ide opencode` always crashes near
    # the end with EACCES when it tries to write ~/.claude/settings.json (which
    # is a read-only nix symlink). The crash happens AFTER the marketplace dist
    # bundle has already been copied to ~/.claude/plugins/marketplaces/thedotmack/dist/,
    # so we let the installer do its bootstrap, swallow the trailing error, then
    # symlink the dist bundle into opencode's plugins dir ourselves.
    #
    # We do NOT inject anything into ~/.config/opencode/AGENTS.md — that path is
    # owned by modules/ai/instructions (read-only nix symlink). The plugin still
    # captures sessions to the SQLite DB; agents query memory via the MCP tools
    # rather than via auto-injected per-session context blobs.
    installClaudeMemOpencodePlugin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      PLUGIN_DEST="$HOME/.config/opencode/plugins/claude-mem.js"
      PLUGIN_SRC="$HOME/.claude/plugins/marketplaces/thedotmack/dist/opencode-plugin/index.js"

      if [ ! -e "$PLUGIN_DEST" ]; then
        # Bootstrap the marketplace dist if it is not already present.
        # npm/npx ship inside pkgs.nodejs — there is no separate pkgs.npm — and
        # the npx wrapper needs `node` on PATH for its #!/usr/bin/env node shebang.
        if [ ! -f "$PLUGIN_SRC" ]; then
          echo "Bootstrapping claude-mem marketplace dist via npx..."
          PATH="${pkgs.nodejs}/bin:$PATH" npx -y claude-mem install --ide opencode || true
        fi

        # Symlink (not copy) so subsequent `npx claude-mem install` runs that
        # update the marketplace dist also update the opencode plugin file.
        if [ -f "$PLUGIN_SRC" ]; then
          mkdir -p "$(dirname "$PLUGIN_DEST")"
          ln -sf "$PLUGIN_SRC" "$PLUGIN_DEST"
          echo "claude-mem opencode plugin linked: $PLUGIN_DEST -> $PLUGIN_SRC"
        else
          echo "WARNING: claude-mem marketplace dist missing — run \`npx claude-mem install --ide opencode\` manually"
        fi
      fi
    '';
  };
}
