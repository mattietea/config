{
  pkgs,
  lib,
  ...
}:
let
  yamlFormat = pkgs.formats.yaml { };
in
{
  home = {
    packages = [ pkgs.omp ];

    file.".omp/agent/config.yml".source = yamlFormat.generate "omp-config.yml" {
      modelRoles = import ./roles.nix;
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
