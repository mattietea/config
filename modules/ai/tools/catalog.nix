{ lib, ... }:
{
  ai.tools =
    lib.genAttrs
      [
        "skill-creator"
        "find-skills"
        "find-docs"
        "agent-browser"
        "playwriter"
        "typescript-advanced-types"
        "vitest"
        "improve-claude-md"
        "git-machete"
        "orchestration"
      ]
      (name: {
        enable = true;
        skills = [ name ];
      })
    // {
      react-testing-library = {
        enable = true;
        skills = [ "itechmeat/react-testing-library" ];
      };
    };
}
