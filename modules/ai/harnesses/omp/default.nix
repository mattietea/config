{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  yamlFormat = pkgs.formats.yaml { };
in
{
  home = {
    # Built from source by the llm-agents flake (same input that provides
    # opencode); tracks upstream releases via `nix flake update`.
    packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp ];

    file.".omp/agent/config.yml".source = yamlFormat.generate "omp-config.yml" {
      modelRoles = import ./roles.nix;
      # omp persists setup-wizard completion into config.yml, which is a
      # read-only nix symlink here — so pin the wizard state declaratively.
      # Bump setupVersion when a new omp release adds onboarding steps
      # (current constant: 1).
      setupVersion = 1;
      providers.webSearch = "auto";
    };

    # Orca launches omp with PI_CODING_AGENT_DIR pointed at a per-workspace
    # overlay directory that has no config.yml, so omp silently falls back to
    # built-in model roles. Mirror the nix-managed config into each existing
    # overlay (same pattern as linkOhMyOpenagentOrcaHookConfig for opencode).
    # Overlays created after the last switch are picked up on the next one.
    # Overlay dirs are nested (<uuid>::/<project path>@@<hash>), so locate the
    # leaves by their agent.db instead of globbing one level.
    activation.linkOmpOrcaOverlayConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ORCA_OVERLAYS_DIR="$HOME/Library/Application Support/orca/pi-agent-overlays"

      if [ -d "$ORCA_OVERLAYS_DIR" ]; then
        ${pkgs.findutils}/bin/find "$ORCA_OVERLAYS_DIR" -maxdepth 8 -type f -name agent.db 2>/dev/null |
          while IFS= read -r db; do
            ln -sf "$HOME/.omp/agent/config.yml" "$(dirname "$db")/config.yml"
          done
      fi
    '';
  };
}
