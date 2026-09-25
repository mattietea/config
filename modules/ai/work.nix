{
  imports = [
    ./harnesses/omp/work.nix
    ./tools/work.nix
    ./mcp/work.nix
    ./instructions/work.nix
  ];

  programs.zsh.initContent = ''
    export ANTHROPIC_API_KEY="$(cat /run/agenix/anthropic-api-key)"
  '';
}
