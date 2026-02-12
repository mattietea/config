{
  inputs,
  ...
}:
{
  imports = [ inputs.agent-skills-nix.homeManagerModules.default ];

  programs.agent-skills = {
    enable = true;
    sources = {
      anthropic = {
        path = inputs.anthropic-skills;
        subdir = "skills";
      };
      vercel = {
        path = inputs.vercel-skills;
        subdir = "skills";
      };
      vercel-cli = {
        path = inputs.vercel-skills-cli;
        subdir = "skills";
      };
    };
    skills.enable = [
      "skill-creator"
      "react-best-practices"
      "composition-patterns"
      "find-skills"
    ];
    targets.claude.enable = true;
  };
}
