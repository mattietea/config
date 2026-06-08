{
  lib,
  config,
  ...
}:
let
  enabled = lib.filter (t: t.enable) (lib.attrValues config.ai.tools);
in
{
  imports = [ ./catalog.nix ];

  options.ai.tools = lib.mkOption {
    default = { };
    description = "AI tools. Enabling one registers its skills, instructions, and packages across every harness.";
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "this AI tool";
          skills = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
          instructions = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
          };
          packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
          };
        };
      }
    );
  };

  config = {
    programs.agent-skills.skills.enable = lib.concatMap (t: t.skills) enabled;
    programs.aiInstructions.segments = lib.filter (x: x != null) (map (t: t.instructions) enabled);
    home.packages = lib.concatMap (t: t.packages) enabled;
  };
}
