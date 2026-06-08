{
  pkgs,
  sources,
  ...
}:
let
  linear-cli = pkgs.stdenv.mkDerivation {
    pname = "linear-cli";
    inherit (sources.linear) version src;

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
