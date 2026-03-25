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
      cmux = {
        path = inputs.cmux-skills;
        subdir = "skills";
      };
    };
    skills.enable = [
      "skill-creator"
      "find-skills"
      "cmux"
    ];
    targets.claude.enable = true;
  };
}
