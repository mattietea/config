{
  config,
  pkgs,
  lib,
  ...
}:
let
  models = import ../../models.nix;
  yamlFormat = pkgs.formats.yaml { };
  secondaryModel = "${models.astra}:high";
  fastModel = "${models.luna}:low";

  roles = import ./roles.nix // {
    smol = fastModel;
    slow = secondaryModel;
    task = "${models.opus}:medium";
    commit = fastModel;
    tiny = fastModel;
    vision = secondaryModel;
    designer = secondaryModel;
    advisor = secondaryModel;
  };
in
{
  home.file.".omp/nix.yml".source = lib.mkForce (
    yamlFormat.generate "omp-config.yml" (
      import ./settings.nix { inherit (config.home) homeDirectory; }
      // {
        modelRoles = roles;
        # Keep code review on a different model from implementation.
        task.agentModelOverrides.reviewer = "@slow";
        tier.openai = "priority";
      }
    )
  );
}
