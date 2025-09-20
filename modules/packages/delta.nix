{
  pkgs,
  ...
}:
{

  programs.git.delta = {
    enable = true;
    package = pkgs.delta;
    options = {
      hyperlinks = true;
      side-by-side = true;
      hyperlinks-file-link-format = "zed://file/{path}:{line}";
    };
  };
}
