{
  pkgs,
  sources,
  ...
}:
{
  home.packages = [ (pkgs.callPackage ./package.nix { inherit sources; }) ];
}
