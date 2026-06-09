{ lib, sources, ... }:
let
  # Tools whose skills come from a shared base source (anthropic et al.) and so
  # carry no source of their own.
  simple =
    lib.genAttrs
      [
        "skill-creator"
        "find-skills"
        "find-docs"
        "typescript-advanced-types"
        "vitest"
      ]
      (name: {
        enable = true;
        skills = [ name ];
      });
in
{
  ai.tools = simple // {
    agent-browser = {
      enable = true;
      skills = [ "agent-browser" ];
      sources.agent-browser = {
        path = sources.agent-browser-skills.src;
        subdir = "skills";
      };
    };
    playwriter = {
      enable = true;
      skills = [ "playwriter" ];
      sources.playwriter = {
        path = sources.playwriter-skills.src;
        subdir = "skills";
      };
    };
    orchestration = {
      enable = true;
      skills = [ "orchestration" ];
      sources.orca = {
        path = sources.orca-skills.src;
        subdir = "skills";
      };
    };
    improve-claude-md = {
      enable = true;
      skills = [ "improve-claude-md" ];
      sources.humanlayer = {
        path = sources.humanlayer-skills.src;
        subdir = "plugins/improve-claude-md/skills";
      };
    };
    git-machete = {
      enable = true;
      skills = [ "git-machete" ];
      sources.local.path = ../skills/git-machete;
    };
    react-testing-library = {
      enable = true;
      skills = [ "itechmeat/react-testing-library" ];
      sources.itechmeat = {
        path = sources.itechmeat-skills.src;
        subdir = "skills";
        idPrefix = "itechmeat";
      };
    };
  };
}
