{
  pkgs,
  lib,
  inputs,
  sources,
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

  # Clean stale opencode runtime state on each activation.
  # model.json holds a remembered model picker that can reference old/invalid models.
  home.activation = {
    cleanOpencodeState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      rm -f "$HOME/.local/state/opencode/model.json"
    '';
  };
}
