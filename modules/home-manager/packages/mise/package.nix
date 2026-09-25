{
  stdenvNoCC,
  installShellFiles,
  lib,
  version,
  src,
}:
stdenvNoCC.mkDerivation {
  pname = "mise";
  inherit version src;

  # The release tarball unpacks to ./mise/{bin,man,share}.
  sourceRoot = "mise";

  nativeBuildInputs = [ installShellFiles ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # bin/mise.d is a stray Cargo depfile from upstream CI; only the binary,
    # its man page, and the fish activation snippet are wanted.
    install -Dm755 bin/mise $out/bin/mise
    installManPage man/man1/mise.1
    install -Dm644 share/fish/vendor_conf.d/mise-activate.fish \
      $out/share/fish/vendor_conf.d/mise-activate.fish

    # mise reads this marker relative to its own prefix and refuses
    # `self-update`, which would otherwise fail against the read-only store.
    install -Dm644 /dev/null $out/lib/mise/.disable-self-update

    runHook postInstall
  '';

  # Generated rather than shipped: the tarball carries no completions. They are
  # self-contained (they shell back into `mise __complete_word__`), so unlike
  # the nixpkgs build there is no `usage` binary path to substitute in.
  postInstall = ''
    export HOME=$(mktemp -d)
    installShellCompletion --cmd mise \
      --bash <($out/bin/mise completion bash) \
      --fish <($out/bin/mise completion fish) \
      --zsh <($out/bin/mise completion zsh)
  '';

  meta = {
    description = "Front-end to your dev env (official prebuilt)";
    homepage = "https://mise.jdx.dev";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "mise";
  };
}
