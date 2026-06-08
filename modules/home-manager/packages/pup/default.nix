{
  pkgs,
  sources,
  ...
}:
let
  pup = pkgs.stdenv.mkDerivation {
    pname = "pup";
    inherit (sources.pup) version src;

    sourceRoot = ".";

    dontBuild = true;

    installPhase = ''
      install -Dm755 pup $out/bin/pup
    '';
  };
in
{
  home.packages = [ pup ];
  home.sessionVariables.DD_SITE = "us3.datadoghq.com";
}
