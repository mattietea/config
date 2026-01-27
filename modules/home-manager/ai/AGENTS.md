# AI Tooling Configuration Module

Shared configuration for claude-code, opencode, and zed.

<!-- AUTO-MANAGED: module-description -->

## Purpose

Central module providing unified configuration for all AI coding tools. Exports MCP servers, rules/instructions, and agent definitions that are automatically transformed and applied to each tool's specific format.

**Responsibilities**:

- Define MCP servers once, use everywhere
- Maintain shared rules and instructions (CLAUDE.md/AGENTS.md content)
- Define custom agents available to all tools
- Export transformable configuration for tool-specific utilities

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: architecture -->

## Module Architecture

```
ai/
├── default.nix      # Exports: { mcpServers, rules, agents }
├── mcp.nix          # MCP server definitions (type: remote|local)
├── rules.nix        # Markdown string for CLAUDE.md/AGENTS.md
└── agents.nix       # Agent definitions (name -> prompt string)
```

**Configuration Flow**:

1. `mcp.nix`, `rules.nix`, `agents.nix` define raw configuration
2. `default.nix` imports and exports as attribute set
3. Each tool imports: `let ai = import ../../ai; in`
4. Tool's `utilities.nix` transforms to tool-specific format:
   - claude-code: remote→http, local→stdio
   - opencode: remote→remote, local→local
   - zed: no type field, just url/command

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: conventions -->

## Module-Specific Conventions

### MCP Server Definition Format

```nix
# mcp.nix structure
{
  server-name = {
    type = "remote";  # or "local"
    url = "https://...";  # for remote
    command = [ "cmd" "arg" ];  # for local
    headers = { ... };  # optional, remote only
    environment = { ... };  # optional, local only
  };
}
```

**Current state**: All MCP servers currently disabled (commented out). Previously configured: context7, grep, exa.

### Rules Format

```nix
# rules.nix - must be a markdown string
''
  # Project Rules
  - Rule 1
  - Rule 2
''
```

**Current rules content** (`rules.nix`):

- **Sisyphus Orchestration Mode**: Defines 11 specialized agents for multi-agent coordination via Task tool
- **Agent roster**: All agents prefixed with `oh-my-claudecode:` (sisyphus-junior, prometheus, oracle, metis, momus, explore, frontend-engineer, document-writer, qa-tester, librarian, multimodal-looker)
- **Delegation strategy**: When to use Task tool (complex tasks, planning, architecture) vs direct execution (simple edits, single tool usage)
- **Magic keywords**: ultrawork (max parallelization), search/find (explore agent), analyze/investigate (oracle agent)
- **Continuation enforcement**: Complete tasks fully before stopping, delegate subtasks when needed

### Agents Format

```nix
# agents.nix - map of name to prompt
{
  agent-name = ''
    Agent prompt text
  '';
  # OR reference file:
  agent-name = ./agents/agent.md;
}
```

### Tool Integration Pattern

Each tool module does:

```nix
let
  utils = import ./utilities.nix { inherit lib; };
  ai = import ../../ai;
in
{
  programs.tool = {
    inherit (utils) mcpServers;  # transformed
    memory.text = ai.rules;       # direct
    inherit (ai) agents;          # direct or transformed
  };
}
```

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: dependencies -->

## Key Dependencies

**Consumed by**:

- `modules/home-manager/packages/claude-code/` - Via utilities.nix transform
- `modules/home-manager/packages/opencode/` - Via utilities.nix transform
- `modules/home-manager/applications/zed/` - Via utilities.nix transform

**External dependencies**:

- None (pure Nix configuration)

**Transform libraries**:

- `claude-code/utilities.nix` - `transformMcpServers` function
- `opencode/utilities.nix` - `transformMcpServers` function
- `zed/utilities.nix` - `transformMcpServers` function

<!-- END AUTO-MANAGED -->

<!-- MANUAL -->

## Custom Notes

Add module-specific notes here.

<!-- END MANUAL -->
