{
  lib,
  pkgs,
  sources,
  ...
}:
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
      packages = [
        pkgs.agent-browser
        pkgs.ffmpeg # video recording (`agent-browser record`)
      ];
      sources.agent-browser = {
        path = sources.agent-browser-skills.src;
        subdir = "skills";
      };
    };
    # The herdr package + config live in modules/home-manager/packages/herdr.
    herdr = {
      enable = true;
      skills = [ "herdr" ];
      sources.herdr = {
        path = sources.herdr-skills.src;
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
    improve-claude-md = {
      enable = true;
      skills = [ "improve-claude-md" ];
      sources.humanlayer = {
        path = sources.humanlayer-skills.src;
        subdir = "plugins/improve-claude-md/skills";
      };
    };
    show-me = {
      enable = true;
      skills = [ "show-me" ];
      sources.humanlayer-show-me = {
        path = sources.humanlayer-skills.src;
        subdir = "plugins/show-me/skills";
      };
    };
    gh-stack = {
      enable = true;
      skills = [ "gh-stack" ];
      sources.gh-stack = {
        path = pkgs.gh-stack.src;
        subdir = "skills";
      };
    };
    # Own take on mattpocock's research skill: same background-agent contract,
    # but findings land in ~/notes (never in a work repo) per the instructions.
    research = {
      enable = true;
      skills = [ "research" ];
      sources.research.path = ../skills/research;
    };
    react-testing-library = {
      enable = true;
      explicitSkills.react-testing-library.from = "itechmeat";
      sources.itechmeat = {
        path = sources.itechmeat-skills.src;
        subdir = "skills";
        idPrefix = "itechmeat";
      };
    };
    # Engineering-process skills from mattpocock/skills, taken verbatim.
    # Repo-touching skills (grill-with-docs, domain-modeling, to-spec,
    # to-tickets, triage) are deliberately excluded — tracker facts live in
    # the instruction files and the Linear-native flow in tools/work.nix.
    mattpocock = {
      enable = true;
      # Explicit flat ids: harnesses only discover skills one directory deep,
      # so the idPrefix-namespaced ids (mattpocock/tdd) would be invisible.
      explicitSkills =
        lib.genAttrs
          [
            "tdd"
            "diagnosing-bugs"
            "prototype"
            "codebase-design"
            "resolving-merge-conflicts"
          ]
          (_: {
            from = "mattpocock-engineering";
          })
        //
          lib.genAttrs
            [
              "grilling"
              "grill-me"
              "handoff"
              "writing-for-agents"
            ]
            (_: {
              from = "mattpocock-productivity";
            });
      sources = {
        mattpocock-engineering = {
          path = sources.mattpocock-skills.src;
          subdir = "skills/engineering";
          idPrefix = "mattpocock";
        };
        mattpocock-productivity = {
          path = sources.mattpocock-skills.src;
          subdir = "skills/productivity";
          idPrefix = "mattpocock";
        };
      };
    };
  };
}
