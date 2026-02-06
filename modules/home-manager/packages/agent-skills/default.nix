{
  inputs,
  ...
}:
{
  imports = [ inputs.agent-skills-nix.homeManagerModules.default ];

  programs.agent-skills = {
    enable = true;
    sources.anthropic = {
      path = inputs.anthropic-skills;
      subdir = "skills";
    };
    sources.vercel = {
      path = inputs.vercel-skills;
      subdir = "skills";
    };
    skills.enable = [
      "skill-creator"
      "react-best-practices"
      "composition-patterns"
    ];
    targets.claude.enable = true;
  };
}
