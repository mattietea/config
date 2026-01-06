_: {
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      # Auto-detect terminal background (from issue #447)
      # Don't set "dark" or "light" - let delta query the terminal
      detect-dark-light = "auto";

      navigate = true; # Use n and N to move between diff sections
      hyperlinks = true;
      line-numbers = true;

      # No syntax-theme set = delta picks appropriate colors based on detection
      # If you want a specific theme, uncomment one:
      # syntax-theme = "GitHub";           # Light terminals
      # syntax-theme = "Visual Studio Dark+"; # Dark terminals (closest to GitHub Dark)
    };
  };
}
