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
      vercel-cli = {
        path = inputs.vercel-skills-cli;
        subdir = "skills";
      };
    };
    skills.enable = [
      "skill-creator"
      "find-skills"
    ];
    targets.claude.enable = true;
  };
}
