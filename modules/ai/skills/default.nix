{
  inputs,
  sources,
  ...
}:
{
  imports = [ inputs.agent-skills-nix.homeManagerModules.default ];

  programs.agent-skills = {
    enable = true;
    # Shared sources that feed multiple base skills (or are not yet owned by a
    # single tool). Tool-specific sources live with their tool in tools/.
    # Pinned via nvfetcher (sources.*.src) rather than flake inputs.
    sources = {
      anthropic = {
        path = sources.anthropic-skills.src;
        subdir = "skills";
      };
      vercel-cli = {
        path = sources.vercel-skills-cli.src;
        subdir = "skills";
      };
      context7 = {
        path = sources.context7-skills.src;
        subdir = "skills";
      };
      wshobson-agents = {
        path = sources.wshobson-agents.src;
        subdir = "plugins/javascript-typescript/skills";
      };
      dot-skills = {
        path = sources.dot-skills.src;
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
