{
  pkgs,
  ...
}:
let
  version = "0.58.3";

  pup = pkgs.stdenv.mkDerivation {
    pname = "pup";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Darwin_arm64.tar.gz";
      hash = "sha256-uqgNjPdDfY/MVDJY/twVUank3TuRfE06KTAETTly6fU=";
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
