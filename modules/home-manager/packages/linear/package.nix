{
  stdenv,
  version,
  src,
}:
stdenv.mkDerivation {
  pname = "linear-cli";
  inherit version src;
  sourceRoot = "linear-aarch64-apple-darwin";
  dontBuild = true;
  installPhase = "install -Dm755 linear $out/bin/linear";
}
