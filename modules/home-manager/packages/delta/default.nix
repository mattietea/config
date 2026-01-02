{
  _,
}:
{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true; # Use n and N to move between diff sections
      hyperlinks = true;
      line-numbers = true;
    };
  };
}
