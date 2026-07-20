{
  pkgs,
  lib,
  ...
}:
let
  models = import ../opencode/models.nix;
  yamlFormat = pkgs.formats.yaml { };

  # Deep reasoning on GPT-5.6 Sol (see the oh-my-openagent agent-model
  # matching guide: GPT temperament fits autonomous deep work).
  roles = import ./roles.nix // {
    slow = "${models.gptStd}:high";
  };
in
{
  home.file.".omp/agent/config.yml".source = lib.mkForce (
    yamlFormat.generate "omp-config.yml" { modelRoles = roles; }
  );
}
