_: {
  programs.agent-skills = {
    sources = {
      pup = {
        input = "pup-skills";
        subdir = "skills";
      };
      linear-cli = {
        input = "linear-cli-skills";
        subdir = "skills";
      };
      worktrunk = {
        input = "worktrunk-skills";
        subdir = "skills";
        filter.maxDepth = 1;
      };
      chrome-devtools-mcp = {
        input = "chrome-devtools-mcp-skills";
        subdir = "skills";
      };
    };
    skills.enable = [
      "dd-pup"
      "dd-monitors"
      "dd-logs"
      "dd-apm"
      "dd-docs"
      "dd-code-generation"
      "dd-file-issue"
      "dd-debugger"
      "dd-symdb"
      "linear-cli"
      "worktrunk"
      "chrome-devtools"
      "chrome-devtools-cli"
      "a11y-debugging"
      "debug-optimize-lcp"
      "memory-leak-debugging"
      "troubleshooting"
    ];
  };
}
