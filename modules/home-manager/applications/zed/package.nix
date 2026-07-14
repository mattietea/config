{
  stdenvNoCC,
  _7zz,
  lib,
  version,
  src,
}:
stdenvNoCC.mkDerivation {
  pname = "zed-editor";
  inherit version src;

  # Zed's dmg is an APFS image, which undmg can't read (HFS only); 7-Zip does.
  nativeBuildInputs = [ _7zz ];

  sourceRoot = ".";
  unpackPhase = "7zz x -snld $src";

  # Zed ships an already-signed+notarized app bundle; stripping/re-signing would
  # invalidate the signature and block launch on Apple Silicon.
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications $out/bin
    cp -r Zed.app $out/Applications/Zed.app
    ln -s $out/Applications/Zed.app/Contents/MacOS/cli $out/bin/zeditor

    runHook postInstall
  '';

  meta = {
    description = "High-performance, multiplayer code editor (official prebuilt)";
    homepage = "https://zed.dev";
    license = lib.licenses.gpl3Only;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "zeditor";
  };
}
