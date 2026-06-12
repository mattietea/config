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
  # force = true so home-manager re-establishes its symlink even after the
  # opencode plugin atomically rewrites the file in place (renameSync), which
  # would otherwise leave a stale user-owned regular file with drifted values
  # (notably git_master.include_co_authored_by) at this path.
  home.file.".config/opencode/oh-my-openagent.json" = {
    force = true;
    text = builtins.toJSON config;
  };
}
