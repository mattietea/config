{
  stdenv,
  version,
  src,
}:
stdenv.mkDerivation {
  pname = "pup";
  inherit version src;
  sourceRoot = ".";
  dontBuild = true;
  installPhase = "install -Dm755 pup $out/bin/pup";
}
