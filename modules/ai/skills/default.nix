{
  inputs,
  ...
}:
{
  imports = [ inputs.agent-skills-nix.homeManagerModules.default ];

  programs.agent-skills = {
    enable = true;
    # Shared sources that feed multiple base skills (or are not yet owned by a
    # single tool). Tool-specific sources live with their tool in tools/.
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
      wshobson-agents = {
        input = "wshobson-agents";
        subdir = "plugins/javascript-typescript/skills";
      };
      dot-skills = {
        input = "dot-skills";
        subdir = "skills/.curated";
      };
    };
    targets = {
      claude.enable = true;
      codex.enable = true;
      agents.enable = true;
    };
  };
}
