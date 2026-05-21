{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:
let
  version = "1.4.16";

  sources = {
    aarch64-darwin = {
      url = "https://github.com/stablyai/orca/releases/download/v${version}/Orca-${version}-arm64-mac.zip";
      hash = "sha256-8SE6BDZmm9PvvILOwVv6RH3bSp+dwm8c4Q7Ail6p7z8=";
    };
    x86_64-darwin = {
      url = "https://github.com/stablyai/orca/releases/download/v${version}/Orca-${version}-mac.zip";
      hash = "sha256-a/8sSmH5pmTcmKkrr9/wyR7fFc/dNzGmu4lT8MhhkY4=";
    };
  };

  system = stdenvNoCC.hostPlatform.system;
  source = sources.${system} or (throw "orca: unsupported system ${system}");
in
stdenvNoCC.mkDerivation {
  pname = "orca";
  inherit version;

  src = fetchurl source;

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications $out/bin
    cp -R "Orca.app" $out/Applications/
    ln -s $out/Applications/Orca.app/Contents/Resources/bin/orca $out/bin/orca
    runHook postInstall
  '';

  meta = {
    description = "Agent Development Environment for running Claude Code, Codex, OpenCode side by side in isolated worktrees";
    homepage = "https://www.onorca.dev/";
    license = lib.licenses.mit;
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
