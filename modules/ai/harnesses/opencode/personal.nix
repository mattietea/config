_:
let
  baseConfig = import ./oh-my-openagent-base.nix;

  # Anthropic-only: disable hephaestus, enable extended thinking for oracle/momus
  config = baseConfig // {
    disabled_agents = [ "hephaestus" ];
    agents = baseConfig.agents // {
      oracle = {
        model = "anthropic/claude-opus-4-7";
        thinking.type = "enabled";
        fallback_models = [
          "anthropic/claude-sonnet-4-6"
        ];
        compaction.model = "anthropic/claude-sonnet-4-6";
      };
      momus = {
        model = "anthropic/claude-opus-4-7";
        thinking.type = "enabled";
        fallback_models = [
          "anthropic/claude-sonnet-4-6"
        ];
        compaction.model = "anthropic/claude-sonnet-4-6";
      };
    };
  };
in
{
  # force = true so home-manager re-establishes its symlink even after the
  # opencode plugin atomically rewrites the file in place (renameSync), which
  # would otherwise leave a stale user-owned regular file with drifted values
  # (notably git_master.include_co_authored_by) at this path.
  home.file.".config/opencode/oh-my-openagent.json" = {
    force = true;
    text = builtins.toJSON config;
  };

  programs.opencode.settings.plugin = [
    "opencode-with-claude"
  ];
}
