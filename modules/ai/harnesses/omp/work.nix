{
  config,
  pkgs,
  lib,
  ...
}:
let
  models = import ../../models.nix;
  yamlFormat = pkgs.formats.yaml { };

  # omp registers ChatGPT-OAuth GPT models under the openai-codex provider.
  gptCodex = lib.replaceStrings [ "openai/" ] [ "openai-codex/" ] models.gptStd;
  roles = import ./roles.nix // {
    slow = "${gptCodex}:high";
    advisor = "${gptCodex}:high";
  };
in
{
  home.file.".omp/nix.yml".source = lib.mkForce (
    yamlFormat.generate "omp-config.yml" (
      import ./settings.nix { inherit (config.home) homeDirectory; } // { modelRoles = roles; }
    )
  );
}
