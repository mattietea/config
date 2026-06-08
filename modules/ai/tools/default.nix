{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    filter
    attrValues
    concatMap
    mkMerge
    mkOption
    mkEnableOption
    types
    ;
  enabled = filter (t: t.enable) (attrValues config.ai.tools);
in
{
  imports = [ ./catalog.nix ];

  options.ai.tools = mkOption {
    default = { };
    description = "AI tools. Enabling one registers its skills, skill sources, instructions, and packages across every harness.";
    type = types.attrsOf (
      types.submodule {
        options = {
          enable = mkEnableOption "this AI tool";
          skills = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };
          sources = mkOption {
            type = types.attrsOf types.anything;
            default = { };
            description = "agent-skills sources this tool provides; merged into programs.agent-skills.sources.";
          };
          instructions = mkOption {
            type = types.nullOr types.path;
            default = null;
          };
          packages = mkOption {
            type = types.listOf types.package;
            default = [ ];
          };
        };
      }
    );
  };

  config = {
    programs = {
      agent-skills = {
        skills.enable = concatMap (t: t.skills) enabled;
        sources = mkMerge (map (t: t.sources) enabled);
      };
      aiInstructions.segments = filter (x: x != null) (map (t: t.instructions) enabled);
    };
    home.packages = concatMap (t: t.packages) enabled;
  };
}
