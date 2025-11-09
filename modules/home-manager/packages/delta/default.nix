{
  pkgs,
  ...
}:
{
  programs.delta = {
    enable = true;
    package = pkgs.delta;
    enableGitIntegration = true;
    options = {
      hyperlinks = true;
      side-by-side = true;
      hyperlinks-file-link-format = "zed://file/{path}:{line}";
    };
  };
}
