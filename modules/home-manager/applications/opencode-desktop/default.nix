{
  inputs,
  pkgs,
  ...
}:
let
  # Workaround for https://github.com/anomalyco/opencode/issues/11755
  # Upstream desktop.nix is missing outputHashes for git dependencies.
  # These hashes need updating when git deps change after `nix flake update`.
  # To fix: set any stale hash to lib.fakeHash, build, copy correct hash from error.
  desktop = inputs.opencode.packages.${pkgs.system}.desktop.overrideAttrs (_: {
    cargoDeps = pkgs.rustPlatform.importCargoLock {
      lockFile = inputs.opencode + "/packages/desktop/src-tauri/Cargo.lock";
      outputHashes = {
        "specta-2.0.0-rc.22" = "sha256-YsyOAnXELLKzhNlJ35dHA6KGbs0wTAX/nlQoW8wWyJQ=";
        "tauri-2.9.5" = "sha256-dv5E/+A49ZBvnUQUkCGGJ21iHrVvrhHKNcpUctivJ8M=";
        "tauri-specta-2.0.0-rc.21" = "sha256-n2VJ+B1nVrh6zQoZyfMoctqP+Csh7eVHRXwUQuiQjaQ=";
      };
    };
  });
in
{
  home.packages = [ desktop ];
}
