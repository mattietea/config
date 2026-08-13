{
  pkgs,
  sources,
  ...
}:
{
  ai.tools = {
    # pup ships the Datadog CLI; its package + DD env live in
    # packages/pup (home.sessionVariables), so only skills + source co-locate here.
    pup = {
      enable = true;
      sources.pup = {
        path = sources.pup-skills.src;
        subdir = "skills";
      };
      skills = [
        "dd-pup"
        "dd-monitors"
        "dd-logs"
        "dd-apm"
        "dd-docs"
        "dd-code-generation"
        "dd-file-issue"
        "dd-debugger"
        "dd-symdb"
      ];
    };
    linear-cli = {
      enable = true;
      sources.linear-cli = {
        path = sources.linear-cli-skills.src;
        subdir = "skills";
      };
      skills = [ "linear-cli" ];
      packages = [ pkgs.linear-cli ];
    };
    # FEPLAT ticket flow: /to-spec writes the agreed spec to ~/notes,
    # /to-tickets scaffolds tracer-slice tickets, /work drives one ticket to a
    # PR. Conventions live in instructions/work.md.
    linear-flow = {
      enable = true;
      skills = [
        "to-spec"
        "to-tickets"
        "work"
      ];
      sources.linear-flow.path = ../skills/linear-flow;
    };
    worktrunk = {
      enable = true;
      sources.worktrunk = {
        path = sources.worktrunk-skills.src;
        subdir = "skills";
        filter.maxDepth = 1;
      };
      skills = [ "worktrunk" ];
    };
    agent-slack = {
      enable = true;
      sources.agent-slack = {
        path = sources.agent-slack-skills.src;
        subdir = "skills";
      };
      skills = [ "agent-slack" ];
      packages = [ pkgs.agent-slack ];
    };
  };
}
