{
  config,
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

    file.".omp/agent/config.yml".source = yamlFormat.generate "omp-config.yml" (
      import ./settings.nix { inherit (config.home) homeDirectory; }
      // {
        modelRoles = import ./roles.nix;
      }
    );

    # Orca launches omp with PI_CODING_AGENT_DIR pointed at a per-workspace
    # overlay directory that has no config.yml, so omp silently falls back to
    # built-in model roles. Mirror the nix-managed config into each existing
    # overlay (same pattern as linkOhMyOpenagentOrcaHookConfig for opencode).
    # Overlays created after the last switch are picked up on the next one.
    # Overlay leaves are hash-suffixed dirs (<uuid>::/<project path>@@<hash>,
    # global-floating-terminal@@<hash>); an agent.db only appears after first
    # use, so match both — leaves like the floating terminal's may otherwise
    # never contain one.
    activation.linkOmpOrcaOverlayConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ORCA_OVERLAYS_DIR="$HOME/Library/Application Support/orca/pi-agent-overlays"

      if [ -d "$ORCA_OVERLAYS_DIR" ]; then
        ${pkgs.findutils}/bin/find "$ORCA_OVERLAYS_DIR" -maxdepth 8 \
          \( -type f -name agent.db -o -type d -name '*@@*' \) 2>/dev/null |
          while IFS= read -r hit; do
            [ -d "$hit" ] || hit="$(dirname "$hit")"
            ln -sf "$HOME/.omp/agent/config.yml" "$hit/config.yml"
          done
      fi
    '';
  };
}
