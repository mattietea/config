{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  yamlFormat = pkgs.formats.yaml { };
in
{
  home = {
    # Built from source by the llm-agents flake; tracks upstream releases
    # via `nix flake update`.
    packages = [
      (pkgs.symlinkJoin {
        name = "omp-configured";
        paths = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/omp --prefix PI_CONFIG_FILES : ${config.home.file.".omp/nix.yml".source}
        '';
      })
    ];

    file.".omp/nix.yml".source = yamlFormat.generate "omp-config.yml" (
      import ./settings.nix { inherit (config.home) homeDirectory; }
      // {
        modelRoles = import ./roles.nix;
      }
    );

    activation.ompWritableConfig = lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ''
      run ${pkgs.writeShellScript "omp-migrate-config" ''
        set -eu
        configFile=${lib.escapeShellArg "${config.home.homeDirectory}/.omp/agent/config.yml"}
        if [[ -L "$configFile" && "$(readlink "$configFile")" == /nix/store/* ]]; then
          temporaryFile=$(mktemp "$configFile.XXXXXX")
          trap 'rm -f "$temporaryFile"' EXIT
          cat "$configFile" > "$temporaryFile"
          chmod 600 "$temporaryFile"
          mv -f "$temporaryFile" "$configFile"
        fi
      ''}
    '';
  };
}
