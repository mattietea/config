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
    description = "AI tools. Enabling one registers its skills, skill sources, and packages across every harness.";
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
          explicitSkills = mkOption {
            type = types.attrsOf types.anything;
            default = { };
            description = "Explicit skill selections (from/path/rename); merged into programs.agent-skills.skills.explicit. Use to expose skills from idPrefix-namespaced sources under flat ids — harnesses only discover skills one directory deep.";
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
    programs.agent-skills = {
      skills.enable = concatMap (t: t.skills) enabled;
      skills.explicit = mkMerge (map (t: t.explicitSkills) enabled);
      sources = mkMerge (map (t: t.sources) enabled);
    };
    home.packages = concatMap (t: t.packages) enabled;
  };
}
