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
      theme = "system";
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
}
