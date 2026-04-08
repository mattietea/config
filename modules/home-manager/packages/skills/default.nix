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
        input = "anthropic-skills";
        subdir = "skills";
      };
      vercel-cli = {
        input = "vercel-skills-cli";
        subdir = "skills";
      };
      context7 = {
        input = "context7-skills";
        subdir = "skills";
      };
    };
    skills.enable = [
      "skill-creator"
      "find-skills"
      "find-docs"
    ];
    targets = {
      claude.enable = true;
      codex.enable = true;
      agents.enable = true;
    };
  };
}
