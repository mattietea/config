# Nix Dotfiles Configuration

Personal nix dotfiles using home-manager, nix-darwin, and nixpkgs.

## Project Structure

- **Modular design**: Each tool gets its own `default.nix`
- **Two hosts**: `personal` and `work` (shared modules, different apps)
- **Tools integrate**: Shell, git, editor integrations work together

```
modules/
├── darwin/system/          # macOS system defaults
└── home-manager/
    ├── applications/       # GUI apps (brave, zed, discord, etc.)
    └── packages/           # CLI tools (git, fzf, zsh, etc.)
```

## Documentation

**Always use context7 to search for nix/home-manager documentation.**

## Adding New Tools

1. **Always try home-manager first** - Check if `programs.<tool>.enable` exists
2. **If no home-manager support** - Use `home.packages = [ pkgs.<tool> ]`
3. **Look at existing integrations** - Check how similar tools are configured
4. **Consider cross-tool integration** - Shell integration, editor integration, etc.

### Directory Structure

- CLI tools: `modules/home-manager/packages/<tool>/default.nix`
- GUI apps: `modules/home-manager/applications/<tool>/default.nix`

### Configuration Patterns

**Simple package** (no home-manager support):

```nix
{ pkgs, ... }:
{
  home.packages = [ pkgs.tool ];
}
```

**Program with home-manager support**:

```nix
{ pkgs, ... }:
{
  programs.tool = {
    enable = true;
    enableZshIntegration = true;  # if available
  };
}
```

**With cross-tool integration** (reference other packages):

```nix
{ pkgs, ... }:
{
  programs.fzf = {
    enable = true;
    fileWidgetOptions = [
      "--preview '${pkgs.bat}/bin/bat --color=always {}'"
    ];
  };
}
```

## AI Tooling Configuration

AI tools (claude-code, opencode, zed) share configuration via the `ai/` module.

### Structure

```
modules/home-manager/
├── ai/                         # Shared AI config (single source of truth)
│   ├── default.nix             # Exports { mcpServers, rules, agents }
│   ├── mcp.nix                 # MCP server definitions
│   ├── rules.nix               # Shared rules/instructions
│   └── agents.nix              # Shared agent definitions
├── packages/
│   ├── claude-code/
│   │   ├── default.nix         # Tool config
│   │   └── utilities.nix       # MCP transform (remote→http, local→stdio)
│   └── opencode/
│       ├── default.nix
│       └── utilities.nix       # MCP transform (remote→remote, local→local)
└── applications/
    └── zed/
        ├── default.nix
        └── utilities.nix       # MCP transform (no type field, just url/command)
```

### Adding MCP Servers

Add to `modules/home-manager/ai/mcp.nix`:

```nix
{
  # Remote HTTP server
  my-server = {
    type = "remote";
    url = "https://example.com/mcp";
    # headers = { Authorization = "Bearer token"; };  # optional
  };

  # Local stdio server
  filesystem = {
    type = "local";
    command = [ "npx" "-y" "@modelcontextprotocol/server-filesystem" "/tmp" ];
    # environment = { VAR = "value"; };  # optional
  };
}
```

The server will automatically be configured in all three tools with the correct format.

### Adding Shared Rules

Edit `modules/home-manager/ai/rules.nix` with markdown content:

```nix
''
  # My Rules
  - Always use TypeScript
  - Follow existing patterns
''
```

This creates `~/.claude/CLAUDE.md` and `~/.config/opencode/AGENTS.md`.

### Adding Shared Agents

Edit `modules/home-manager/ai/agents.nix`:

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

## Run within devenv

Before running any commands, ensure you're in the devenv shell:

```sh
devenv shell
```

**Or run a single command without entering the shell:**

```sh
devenv shell -- command
```

Examples:

```sh
devenv shell -- format
devenv shell -- "format && lint"
```

## Available Commands

- `switch` - Apply changes to nix-darwin
- `format` - Format all files (uses treefmt with nixfmt, prettier, yamlfmt)
- `lint` - Lint Nix files (uses statix)
- `update` - Update flake inputs
- `clean` - Clean up old Nix generations

Run these commands from within the devenv shell.
