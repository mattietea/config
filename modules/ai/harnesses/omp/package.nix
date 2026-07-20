{
  lib,
  stdenvNoCC,
  version,
  src,
}:
stdenvNoCC.mkDerivation {
  pname = "omp";
  inherit version src;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/omp"
    runHook postInstall
  '';

  meta = {
    description = "oh my pi — a coding agent with the IDE wired in";
    homepage = "https://omp.sh";
    license = lib.licenses.mit;
    mainProgram = "omp";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
