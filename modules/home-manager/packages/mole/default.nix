{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  version = inputs.mole-src.shortRev or "latest";

  # Build the two Go helper binaries
  mole-go-helpers = pkgs.buildGoModule {
    pname = "mole-go-helpers";
    inherit version;
    src = inputs.mole-src;

    # Use proxyVendor to bypass out-of-sync vendor directory in upstream
    proxyVendor = true;

    # Sync dependencies after vendor creation
    overrideModAttrs = _: { modPostBuild = "go mod tidy"; };

    vendorHash = "sha256-QckRB0j/RvKbGTWDcNTcPxlfREKxOwTzY9abtUeRsZI=";

    # Tests require macOS Trash which doesn't work in Nix sandbox
    doCheck = false;

    subPackages = [
      "cmd/analyze"
      "cmd/status"
    ];

    ldflags = [
      "-s"
      "-w"
      "-X main.Version=${version}"
    ];

    # Rename to match expected names (analyze-go, status-go)
    postInstall = ''
      mv $out/bin/analyze $out/bin/analyze-go
      mv $out/bin/status $out/bin/status-go
    '';

    meta = {
      description = "Go helper binaries for Mole";
      platforms = [ "aarch64-darwin" ];
    };
  };

  # Build the full Mole package (bash scripts + Go helpers)
  mole = pkgs.stdenv.mkDerivation {
    pname = "mole";
    inherit version;
    src = inputs.mole-src;

    nativeBuildInputs = [ pkgs.makeWrapper ];

    # Skip build phase - we already built Go binaries separately
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/libexec $out/bin

      # Install bash scripts and libraries
      cp -r bin lib $out/libexec/

      # Install Go helpers
      cp ${mole-go-helpers}/bin/analyze-go $out/libexec/bin/
      cp ${mole-go-helpers}/bin/status-go $out/libexec/bin/

      # Patch and install main mole script
      substitute mole $out/bin/mole \
        --replace 'SCRIPT_DIR="$(cd "$(dirname "''${BASH_SOURCE[0]}")" && pwd)"' \
                  "SCRIPT_DIR='$out/libexec'"

      chmod +x $out/bin/mole
      chmod +x $out/libexec/bin/*.sh

      # Create mo symlink
      ln -s $out/bin/mole $out/bin/mo

      runHook postInstall
    '';

    meta = with lib; {
      description = "Deep clean and optimize your Mac";
      homepage = "https://github.com/tw93/Mole";
      license = licenses.mit;
      platforms = [ "aarch64-darwin" ];
      mainProgram = "mole";
    };
  };
in
{
  home.packages = [ mole ];
}
