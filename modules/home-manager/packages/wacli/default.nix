{
  pkgs,
  lib,
  ...
}:
let
  version = "0.9.2";
  wacli = pkgs.stdenvNoCC.mkDerivation {
    pname = "wacli";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/openclaw/wacli/releases/download/v${version}/wacli-macos-universal.tar.gz";
      hash = "sha256-nWH7v3Eoytq11MPK/eO24U99O4e9//POUF7MRYujK8Q=";
    };

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
  };
in
{
  home.packages = [ wacli ];
}
