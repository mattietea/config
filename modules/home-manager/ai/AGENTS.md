# Shared AI Configuration Module

This module provides shared configuration for AI coding tools (claude-code, opencode, zed).

## Files

- `default.nix` - Exports `{ mcpServers, rules, agents }`
- `mcp.nix` - MCP server definitions (single source of truth)
- `rules.nix` - Shared rules/instructions (empty by default)
- `agents.nix` - Shared agent definitions (empty by default)

## Adding MCP Servers

Edit `mcp.nix`:

```nix
{
  # Remote HTTP server
  my-server = {
    type = "remote";
    url = "https://example.com/mcp";
    # headers = { Authorization = "Bearer token"; };
  };

  # Local stdio server
  filesystem = {
    type = "local";
    command = [ "npx" "-y" "@modelcontextprotocol/server-filesystem" "/tmp" ];
    # environment = { VAR = "value"; };
  };
}
```

Each tool transforms this to its format via `utilities.nix`:

| Tool        | Remote            | Local                               |
| ----------- | ----------------- | ----------------------------------- |
| claude-code | `type = "http"`   | `type = "stdio"`, `command`, `args` |
| opencode    | `type = "remote"` | `type = "local"`, `command`         |
| zed         | `url` only        | `command`, `args`                   |

## Adding Shared Rules

Edit `rules.nix` with markdown content:

```nix
''
  # My Rules
  - Always use TypeScript
  - Follow existing patterns
''
```

This populates:

- claude-code: `~/.claude/CLAUDE.md`
- opencode: `~/.config/opencode/AGENTS.md`

## Adding Shared Agents

Edit `agents.nix`:

```nix
{
  code-reviewer = ''
    # Code Reviewer Agent
    You are a senior engineer specializing in code reviews.
  '';
  # Or reference a file:
  # documentation = ./agents/documentation.md;
}
```

Both claude-code and opencode support this format.
