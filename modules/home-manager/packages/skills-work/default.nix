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
    ];
  };
}
