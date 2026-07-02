_: {
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      # Auto-detect terminal background (from issue #447)
      # Don't set "dark" or "light" - let delta query the terminal
      detect-dark-light = "auto";

      paging = "auto";
      navigate = true; # Use n and N to move between diff sections
      hyperlinks = true;
      line-numbers = true;
    };
  };
}
