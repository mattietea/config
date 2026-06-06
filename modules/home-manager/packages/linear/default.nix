{
  pkgs,
  ...
}:
let
  version = "2.0.0";

  linear-cli = pkgs.stdenv.mkDerivation {
    pname = "linear-cli";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/schpet/linear-cli/releases/download/v${version}/linear-aarch64-apple-darwin.tar.xz";
      hash = "";
    };

    sourceRoot = "linear-aarch64-apple-darwin";

    dontBuild = true;

    installPhase = ''
      install -Dm755 linear $out/bin/linear
    '';
  };
in
{
  home.packages = [ linear-cli ];
}
