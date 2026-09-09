{
  config,
  pkgs,
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
  };
}
