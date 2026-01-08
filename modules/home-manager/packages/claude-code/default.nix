_: {

  programs.claude-code = {
    enable = true;
    settings = {
      enabledPlugins = {
        "context7@claude-plugins-official" = true;
      };
    };
  };
}
