{
  pkgs,
  lib,
  ...
}:
let
  models = import ../../models.nix;
  yamlFormat = pkgs.formats.yaml { };

  # Deep reasoning on GPT-5.6 Sol (see the oh-my-openagent agent-model
  # matching guide: GPT temperament fits autonomous deep work). omp registers
  # ChatGPT-OAuth GPT models under the openai-codex provider (opencode uses
  # openai/), so remap the shared id's prefix for omp's registry.
  gptCodex = lib.replaceStrings [ "openai/" ] [ "openai-codex/" ] models.gptStd;
  roles = import ./roles.nix // {
    slow = "${gptCodex}:high";
    advisor = "${gptCodex}:high";
  };
in
{
  home.file.".omp/agent/config.yml".source = lib.mkForce (
    yamlFormat.generate "omp-config.yml" (import ./settings.nix // { modelRoles = roles; })
  );
}
