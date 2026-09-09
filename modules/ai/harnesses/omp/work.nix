{
  config,
  pkgs,
  lib,
  ...
}:
let
  models = import ../../models.nix;
  yamlFormat = pkgs.formats.yaml { };
  primaryModel = "${models.astra}:high";
  fastModel = "${models.luna}:low";

  roles = import ./roles.nix // {
    default = primaryModel;
    smol = fastModel;
    slow = "${models.astra}:xhigh";
    plan = primaryModel;
    task = primaryModel;
    commit = fastModel;
    tiny = fastModel;
    vision = primaryModel;
    designer = primaryModel;
    advisor = "${models.fable}:high";
  };
in
{
  home.file.".omp/nix.yml".source = lib.mkForce (
    yamlFormat.generate "omp-config.yml" (
      import ./settings.nix { inherit (config.home) homeDirectory; }
      // {
        modelRoles = roles;
        tier.openai = "priority";
      }
    )
  );
}
