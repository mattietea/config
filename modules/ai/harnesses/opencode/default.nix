{
  pkgs,
  lib,
  inputs,
  config,
  sources,
  ...
}:
let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

  # claude-mem ships an opencode plugin under its Claude Code marketplace bundle.
  # It uses fire-and-forget HTTP to the worker daemon, so the worker must be
  # running (it auto-starts via the claude-mem MCP server). The bundle is
  # installed by `npx claude-mem install --ide opencode`.
  claudeMemOpencodePlugin = "${config.home.homeDirectory}/.config/opencode/plugins/claude-mem.js";
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
        # Version tracked by nvfetcher (nvfetcher.toml → _sources/generated.nix).
        # Bump by running `nvfetcher`, not by editing here. Version-keyed so
        # opencode's bun cache stays deterministic.
        "oh-my-openagent@${sources.oh-my-openagent.version}"
        "file://${claudeMemOpencodePlugin}"
      ];
    };
    tui = {
      theme = "system";
    };
  };

  # The claude-mem opencode plugin defaults to worker port 37700 + (uid % 100),
  # but the worker actually runs on 37777 (set in ~/.claude-mem/settings.json).
  # Override here so the plugin POSTs to the real worker.
  home.sessionVariables.CLAUDE_MEM_WORKER_PORT = "37777";

  # Clean stale opencode runtime state on each activation.
  # model.json holds a remembered model picker that can reference old/invalid models.
  # The plugin creates .bak.* and .migrations.json files when it tries (and fails)
  # to rewrite the nix-managed read-only symlink.
  # (oh-my-openagent is now version-pinned in the plugin list above, so the bun
  # cache is version-keyed and refetches on bump — the @latest cache wipe is gone.)
  home.activation = {
    cleanOpencodeState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      rm -f "$HOME/.local/state/opencode/model.json"
      rm -f "$HOME/.config/opencode/oh-my-openagent.json.bak."*
      rm -f "$HOME/.config/opencode/oh-my-openagent.json.migrations.json"
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
  };
}
