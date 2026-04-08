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
    ];
  };
}
