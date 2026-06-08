{
  inputs,
  pkgs,
  ...
}:
{
  ai.tools = {
    # pup ships the Datadog CLI; its package + DD env live in
    # packages/pup (home.sessionVariables), so only skills + source co-locate here.
    pup = {
      enable = true;
      sources.pup = {
        input = "pup-skills";
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
        input = "linear-cli-skills";
        subdir = "skills";
      };
      skills = [ "linear-cli" ];
      packages = [ pkgs.linear-cli ];
    };
    worktrunk = {
      enable = true;
      sources.worktrunk = {
        input = "worktrunk-skills";
        subdir = "skills";
        filter.maxDepth = 1;
      };
      skills = [ "worktrunk" ];
    };
    chrome-devtools = {
      enable = true;
      sources.chrome-devtools-mcp = {
        input = "chrome-devtools-mcp-skills";
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
        input = "agent-slack";
        subdir = "skills";
      };
      skills = [ "agent-slack" ];
      packages = [ inputs.agent-slack.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    };
  };
}
