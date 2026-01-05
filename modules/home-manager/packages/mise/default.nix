{
  pkgs,
  ...
}:
{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      experimental = true;
    };
  };
}
