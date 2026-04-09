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
      agent-browser = {
        input = "agent-browser-skills";
        subdir = "skills";
      };
      wshobson-agents = {
        input = "wshobson-agents";
        subdir = "plugins/javascript-typescript/skills";
      };
      dot-skills = {
        input = "dot-skills";
        subdir = "skills/.curated";
      };
      itechmeat = {
        input = "itechmeat-skills";
        subdir = "skills";
        idPrefix = "itechmeat";
      };
      humanlayer = {
        input = "humanlayer-skills";
        subdir = "plugins/improve-claude-md/skills";
      };
    };
    skills.enable = [
      "skill-creator"
      "find-skills"
      "find-docs"
      "agent-browser"
      "typescript-advanced-types"
      "vitest"
      "itechmeat/react-testing-library"
      "improve-claude-md"
    ];
    targets = {
      claude.enable = true;
      codex.enable = true;
      agents.enable = true;
    };
  };
}
