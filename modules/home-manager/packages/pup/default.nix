{
  pkgs,
  ...
}:
let
  version = "0.49.2";

  pup = pkgs.stdenv.mkDerivation {
    pname = "pup";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Darwin_arm64.tar.gz";
      hash = "sha256-8qsq70A9driC+MqmtOEpOCsorB6MYkMcmeY5VdkE3BI=";
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
