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

  # The .app bundle is a signed Electron app. Nix's default fixupPhase patches
  # shebangs in shell scripts inside the bundle, which invalidates the code
  # signature and causes macOS Gatekeeper to refuse to launch it ("damaged").
  # Disable fixup entirely and re-sign with an ad-hoc signature after install.
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications $out/bin
    cp -R "Orca.app" $out/Applications/
    ln -s $out/Applications/Orca.app/Contents/Resources/bin/orca $out/bin/orca

    # Re-sign the bundle ad-hoc so Gatekeeper accepts it. Any prior signature
    # was invalidated by the copy + Nix's store rewriting.
    /usr/bin/codesign --force --deep --sign - "$out/Applications/Orca.app"

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
