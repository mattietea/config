{
  inputs,
  pkgs,
  ...
}:
{
  home.packages = [ inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
