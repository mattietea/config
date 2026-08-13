{
  imports = [
    ./harnesses/claude-code
    ./harnesses/codex
    # Disabled. All claude-mem wiring (Claude Code/Codex/OpenCode plugins, MCP
    # server, env vars, runtime install) lives in that module — uncommenting
    # this import re-enables the whole integration.
    # ./integrations/claude-mem
    ./harnesses/opencode
    ./harnesses/omp
    ./skills
    ./tools
    ./mcp
    ./instructions
  ];
}
