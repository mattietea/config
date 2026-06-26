{
  lib,
  stdenvNoCC,
  version,
  src,
}:
stdenvNoCC.mkDerivation {
  pname = "agent-slack";
  inherit version src;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/agent-slack"
    runHook postInstall
  '';

  meta = {
    description = "Slack automation CLI for AI agents";
    homepage = "https://github.com/stablyai/agent-slack";
    license = lib.licenses.mit;
    mainProgram = "agent-slack";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
