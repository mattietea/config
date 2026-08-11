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
  # Temporarily disabled:
  # claudeMemOpencodePlugin = "${config.home.homeDirectory}/.config/opencode/plugins/claude-mem.js";
in
{
  programs.opencode = {
    enable = true;
    package = llm-agents.opencode;
    enableMcpIntegration = true;
    settings = {
      "$schema" = "https://opencode.ai/config.json";
      share = "disabled";
      # Hide OpenCode Zen (provider id "opencode") from the model picker —
      # all agents run on anthropic/openai models (see models.nix).
      disabled_providers = [ "opencode" ];
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
        # "file://${claudeMemOpencodePlugin}"  # temporarily disabled
      ];
    };
    tui = {
      theme = "system";
      # The TUI loads plugins from its own list; without this entry the
      # oh-my-openagent sidebar/commands vanish until opencode rewrites
      # tui.json at runtime.
      plugin = [ "oh-my-openagent@${sources.oh-my-openagent.version}" ];
    };
  };

  # opencode rewrites tui.json at runtime (pinning the resolved plugin
  # version), so every activation tries to back it up and trips over the
  # previous switch's backup. Overwrite instead — opencode regenerates its
  # runtime edits on next launch.
  xdg.configFile."opencode/tui.json".force = true;

  # The claude-mem opencode plugin defaults to worker port 37700 + (uid % 100),
  # but the worker actually runs on 37777 (set in ~/.claude-mem/settings.json).
  # Override here so the plugin POSTs to the real worker.
  # Temporarily disabled:
  # home.sessionVariables.CLAUDE_MEM_WORKER_PORT = "37777";

  # Clean stale opencode runtime state on each activation.
  # model.json holds a remembered model picker that can reference old/invalid models.
  home.activation = {
    cleanOpencodeState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      rm -f "$HOME/.local/state/opencode/model.json"
    '';

    # oh-my-openagent 5.x reads its config from ~/.omo/omo.jsonc only. Remove
    # the 4.x-era config mirrors previously symlinked into Orca's
    # OPENCODE_CONFIG_DIR hook dirs (they now dangle).
    cleanOrcaHookConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ORCA_HOOKS_DIR="$HOME/Library/Application Support/orca/opencode-hooks"

      if [ -d "$ORCA_HOOKS_DIR" ]; then
        find "$ORCA_HOOKS_DIR" -maxdepth 2 -name oh-my-openagent.json -type l -delete
      fi
    '';
  };
}
