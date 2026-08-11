_:
let
  baseConfig = import ./oh-my-openagent-base.nix;

  # Anthropic-only: disable hephaestus (OpenAI-backed). The base agents already
  # run Opus with extended thinking and Sonnet fallback, so no overrides needed.
  config = baseConfig // {
    disabled_agents = [ "hephaestus" ];
  };
in
{
  # oh-my-openagent 5.x reads its unified config from ~/.omo/omo.jsonc (the
  # legacy ~/.config/opencode/oh-my-openagent.json is treated as a migration
  # source it can never delete out of the read-only nix store). Manage the
  # unified file directly, harness-scoped under "[opencode]", with the
  # migration marker so the plugin never re-runs the legacy migration.
  # force = true so home-manager re-establishes its symlink even after the
  # plugin atomically rewrites the file in place (renameSync), which would
  # otherwise leave a stale user-owned regular file at this path.
  home.file.".omo/omo.jsonc" = {
    force = true;
    text = builtins.toJSON {
      "$schema" =
        "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/omo.schema.json";
      "[opencode]" = config;
      _migrations = [ "2026-07-opencode-config-unification" ];
    };
  };
}
