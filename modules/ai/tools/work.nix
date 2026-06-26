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
    worktrunk = {
      enable = true;
      sources.worktrunk = {
        path = sources.worktrunk-skills.src;
        subdir = "skills";
        filter.maxDepth = 1;
      };
      skills = [ "worktrunk" ];
    };
    chrome-devtools = {
      enable = true;
      sources.chrome-devtools-mcp = {
        path = sources.chrome-devtools-mcp-skills.src;
        subdir = "skills";
      };
      skills = [
        "chrome-devtools"
        "chrome-devtools-cli"
        "a11y-debugging"
        "debug-optimize-lcp"
        "memory-leak-debugging"
        "troubleshooting"
      ];
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
