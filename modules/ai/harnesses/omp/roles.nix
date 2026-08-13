# Base model-role assignments for omp (https://omp.sh/docs/roles).
# Anthropic-only so the personal host works as-is; work swaps `slow`
# to GPT in ./work.nix. Model ids come from the shared models.nix.
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
