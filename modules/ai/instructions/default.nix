{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.aiInstructions;
  mergedFile = pkgs.writeText "ai-instructions.md" (
    lib.concatMapStringsSep "\n\n" builtins.readFile cfg.segments
  );
in
{
  options.programs.aiInstructions = {
    segments = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = ''
        Markdown files concatenated (in order) to form the final AI instructions
        file deployed to every configured harness (Claude Code, Codex, OpenCode).
        The base module contributes `INSTRUCTIONS.md`; host aggregators
        (`work.nix`, `personal.nix`) append their own segments.
      '';
    };
  };

  config = {
    # Anchor the base instructions at the start of the merged file. Host
    # aggregators (work.nix / personal.nix) append their own segments after.
    programs.aiInstructions.segments = lib.mkBefore [ ./INSTRUCTIONS.md ];

    home.file =
      lib.genAttrs
        [
          ".claude/CLAUDE.md"
          ".codex/AGENTS.md"
          ".config/opencode/AGENTS.md"
        ]
        (_: {
          source = mergedFile;
        });
  };
}
