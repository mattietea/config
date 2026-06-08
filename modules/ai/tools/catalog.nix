{ lib, ... }:
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
        input = "agent-browser-skills";
        subdir = "skills";
      };
    };
    playwriter = {
      enable = true;
      skills = [ "playwriter" ];
      sources.playwriter = {
        input = "playwriter-skills";
        subdir = "skills";
      };
    };
    orchestration = {
      enable = true;
      skills = [ "orchestration" ];
      sources.orca = {
        input = "orca-skills";
        subdir = "skills";
      };
    };
    improve-claude-md = {
      enable = true;
      skills = [ "improve-claude-md" ];
      sources.humanlayer = {
        input = "humanlayer-skills";
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
        input = "itechmeat-skills";
        subdir = "skills";
        idPrefix = "itechmeat";
      };
    };
  };
}
