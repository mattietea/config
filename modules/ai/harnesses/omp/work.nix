{
  pkgs,
  lib,
  ...
}:
let
  models = import ../../models.nix;
  yamlFormat = pkgs.formats.yaml { };

  # Deep reasoning on GPT-5.6 Sol (see the oh-my-openagent agent-model
  # matching guide: GPT temperament fits autonomous deep work).
  roles = import ./roles.nix // {
    slow = "${models.gptStd}:high";
    advisor = "${models.gptStd}:high";
  };
in
{
  home.file.".omp/agent/config.yml".source = lib.mkForce (
    yamlFormat.generate "omp-config.yml" {
      modelRoles = roles;
      # Keep in sync with ./default.nix — wizard state must be pinned in
      # every config.yml variant (read-only nix symlink).
      setupVersion = 1;
      providers.webSearch = "auto";
      astGrep.enabled = true;
      memory.backend = "mnemopi";
      autolearn.enabled = true;
      advisor.enabled = true;
    }
  );
}
