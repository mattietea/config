{
  pkgs,
  ...
}:
let
  version = "0.45.1";

  pup = pkgs.stdenv.mkDerivation {
    pname = "pup";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Darwin_arm64.tar.gz";
      hash = "sha256-tNiTakRvm7gaFyU3QLaFt34NRpWckD+HotqpB7LvNoo=";
    };

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
