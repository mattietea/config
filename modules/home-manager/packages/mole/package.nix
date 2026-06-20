{
  lib,
  buildGoModule,
  makeWrapper,
  version,
  src,
}:
buildGoModule {
  pname = "mole";
  inherit version src;

  # cmd/analyze and cmd/status are the only Go entrypoints; the rest of the CLI
  # is bash (mole/mo + lib/ + bin/*.sh) that shells out to these two binaries.
  subPackages = [
    "cmd/analyze"
    "cmd/status"
  ];

  vendorHash = "sha256-HcCJ3DYj5AXX+E5AD6jxBysCq4TAoIs2I6oVN4dCBxQ=";

  # Release builds are pure-Go (Makefile sets CGO_ENABLED=0); match that so the
  # gopsutil dependency uses its cgo-free path.
  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
  ];

  # The Go tests exercise macOS userland (e.g. BSD `du -I`) that the Nix builder
  # doesn't provide; upstream runs them on real macOS, so skip them here.
  doCheck = false;

  nativeBuildInputs = [ makeWrapper ];

  # Assemble the bash CLI next to the freshly built Go binaries. The shell
  # scripts exec their siblings as bin/analyze-go and bin/status-go (e.g.
  # bin/analyze.sh: GO_BIN="$SCRIPT_DIR/analyze-go"), and mole resolves lib/ and
  # bin/ relative to its own path, so the whole tree lives under libexec and
  # mole/mo become thin wrappers that exec it.
  postInstall = ''
    libexec=$out/libexec/mole
    mkdir -p $libexec
    cp -r lib bin mole mo $libexec/

    install -Dm755 $out/bin/analyze $libexec/bin/analyze-go
    install -Dm755 $out/bin/status $libexec/bin/status-go
    rm $out/bin/analyze $out/bin/status

    patchShebangs $libexec/mole $libexec/mo $libexec/bin

    makeWrapper $libexec/mole $out/bin/mole
    makeWrapper $libexec/mole $out/bin/mo
  '';

  meta = {
    description = "Clean, uninstall, analyze, optimize, and monitor your Mac from the terminal";
    homepage = "https://github.com/tw93/mole";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.darwin;
    mainProgram = "mole";
  };
}
