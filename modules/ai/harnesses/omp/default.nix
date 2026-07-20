{
  pkgs,
  ...
}:
let
  yamlFormat = pkgs.formats.yaml { };
in
{
  home.packages = [ pkgs.omp ];

  home.file.".omp/agent/config.yml".source = yamlFormat.generate "omp-config.yml" {
    modelRoles = import ./roles.nix;
  };
}
