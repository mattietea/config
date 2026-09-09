# Base model-role assignments for omp (https://omp.sh/docs/roles).
# Anthropic-only for the personal host; work overrides roles in ./work.nix.
let
  models = import ../../models.nix;
in
{
  default = "${models.fable}:high";
  smol = models.haiku;
  slow = "${models.fable}:high";
  plan = "${models.fable}:high";
  task = models.sonnet;
  commit = models.haiku;
  vision = models.sonnet;
  designer = models.sonnet;
  advisor = "${models.sonnet}:medium";
}
