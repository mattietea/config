{
  stdenvNoCC,
  lib,
  version,
  src,
}:
stdenvNoCC.mkDerivation {
  pname = "wacli";
  inherit version src;

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 wacli $out/bin/wacli
    install -Dm644 LICENSE $out/share/licenses/wacli/LICENSE
    runHook postInstall
  '';

  meta = {
    description = "WhatsApp CLI for syncing, searching, and sending from local scripts";
    homepage = "https://github.com/openclaw/wacli";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "wacli";
  };
}
