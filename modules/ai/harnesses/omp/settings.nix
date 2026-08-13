# Shared config.yml payload for omp. Each host variant merges its own
# modelRoles on top (base roles in ./default.nix, work roles in ./work.nix).
{ homeDirectory }:
{
  # omp persists setup-wizard completion into config.yml, which is a
  # read-only nix symlink here — so pin the wizard state declaratively.
  # Bump setupVersion when a new omp release adds onboarding steps
  # (current constant: 1).
  setupVersion = 1;
  providers.webSearch = "auto";
  astGrep.enabled = true;
  followUpMode = "all";
  memory.backend = "mnemopi";
  mnemopi = {
    # One shared bank across every project instead of per-project isolation.
    scoping = "global";
    polyphonicRecall = true;
    enhancedRecall = true;
    proactiveLinking = true;
  };
  autolearn = {
    enabled = true;
    # Auto-run one capture turn at stop instead of a passive reminder.
    autoContinue = true;
  };
  # Only nix-managed skills. Disabling every named source toggle also turns
  # off the toggle-less providers (github .github/skills, opencode,
  # claude-plugins), which stay active while ANY named source is enabled —
  # so project repos can't inject skills from any layout. The user skill set
  # is served back through customDirectories instead.
  skills = {
    enableCodexUser = false;
    enableClaudeUser = false;
    enableClaudeProject = false;
    enablePiUser = false;
    enablePiProject = false;
    enableAgentsUser = false;
    enableAgentsProject = false;
    customDirectories = [ "${homeDirectory}/.agents/skills" ];
  };
  advisor.enabled = true;
}
