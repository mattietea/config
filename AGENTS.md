# Nix Dotfiles Configuration

Personal macOS system configuration using Nix Flakes, nix-darwin, and home-manager.

<!-- AUTO-MANAGED: project-description -->

## Overview

Declarative macOS dotfiles managing system settings, GUI applications, and CLI tools across two hosts (personal and work). Features modular architecture with 45+ tool configurations, shared AI tooling setup, and integrated development environment via devenv.

**Key Features**:

- Modular tool configurations (each tool gets own `default.nix`)
- Two host configurations with shared modules
- Unified AI tool configuration (claude-code, opencode, zed)
- Cross-tool integrations (fzf + bat/eza, git + delta)
- Reproducible builds via Nix flakes

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: build-commands -->

## Build & Development Commands

All commands run within `devenv shell`:

```bash
# Apply system changes (requires sudo)
switch

# Code quality
format    # Format Nix, YAML, and markdown files (treefmt)
lint      # Lint Nix files (statix)

# Maintenance
update    # Update flake and devenv inputs
clean     # Run garbage collection
```

**Git hooks** (auto-run on commit):

- treefmt (formatting)
- statix (Nix linting)
- shellcheck (shell script linting)
- flake-check (validate flake structure)

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: architecture -->

## Architecture

```
.
├── flake.nix                    # Flake inputs and outputs
├── devenv.nix                   # Development environment & scripts
├── hosts/
│   ├── personal/default.nix     # Personal MacBook Air config
│   └── work/default.nix         # Work MacBook Pro config
└── modules/
    ├── darwin/system/           # macOS system defaults
    └── home-manager/
        ├── ai/                  # Shared AI config (claude-code, opencode, zed)
        │   ├── default.nix      # Exports: mcpServers, rules, agents
        │   ├── mcp.nix          # MCP server definitions
        │   ├── rules.nix        # Shared CLAUDE.md/AGENTS.md content
        │   └── agents.nix       # Agent definitions
        ├── applications/        # GUI apps (brave, zed, discord, etc.)
        │   └── */default.nix
        └── packages/            # CLI tools (git, fzf, zsh, etc.)
            └── */default.nix
```

**Data Flow**:

1. `hosts/{personal,work}/default.nix` imports modules via `sharedModules`
2. Each module configures a tool using home-manager or `home.packages`
3. AI tools import shared config from `modules/home-manager/ai/`
4. Cross-tool integrations reference other packages via `${pkgs.tool}/bin/tool`

**Key Files**:

- `flake.nix` - Defines inputs (nixpkgs, darwin, home-manager, opencode)
- `devenv.nix` - Scripts (switch, format, lint) and git hooks
- `hosts/*/default.nix` - Host-specific module lists and settings
- `modules/home-manager/ai/default.nix` - Single source of truth for AI config

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: conventions -->

## Code Conventions

### Module Structure

**Standard module template**:

```nix
{
  pkgs,
  ...
}:
{
  programs.tool = {
    enable = true;
    enableZshIntegration = true;  # if available
    # ... tool-specific config
  };
}
```

**Without home-manager support**:

```nix
{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.tool ];
}
```

### Naming Conventions

- Module directories: `lowercase-with-dashes` (e.g., `git-absorb/`)
- Files: Always `default.nix` (exceptions: `utilities.nix`, `mcp.nix`, etc.)
- Settings parameter: Passed via `specialArgs` in host config

### Import Patterns

```nix
# Host imports modules as paths
sharedModules = [
  ../../modules/home-manager/packages/git
  ../../modules/home-manager/packages/fzf
];

# Modules import shared config
let
  ai = import ../../ai;
in
```

### Cross-Tool Integration

Reference other tools via full package path:

```nix
fileWidgetOptions = [
  "--preview '${pkgs.bat}/bin/bat --color=always {}'"
];
```

### AI Tool Configuration

All AI tools (claude-code, opencode, zed) share:

- MCP servers from `modules/home-manager/ai/mcp.nix`
- Rules/instructions from `modules/home-manager/ai/rules.nix`
- Agent definitions from `modules/home-manager/ai/agents.nix`

Each tool has `utilities.nix` to transform shared config to tool-specific format.

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: patterns -->

## Detected Patterns

### 1. Modular Tool Configuration

Each tool gets its own directory under `packages/` or `applications/`:

- `packages/git/default.nix` - Git configuration
- `packages/fzf/default.nix` - FZF configuration
- `applications/zed/default.nix` - Zed editor

### 2. Home-Manager First Approach

Prefer `programs.<tool>` over `home.packages` when available:

```nix
# Preferred
programs.git.enable = true;

# Fallback
home.packages = [ pkgs.tool ];
```

### 3. Shell Integration

Tools with shell integration enable it explicitly:

```nix
programs.fzf = {
  enable = true;
  enableZshIntegration = true;
};
```

### 4. Shared Configuration Pattern

AI tools use a unified config module:

```nix
let
  ai = import ../../ai;
in
{
  programs.claude-code = {
    inherit (ai) agents;
    memory.text = ai.rules;
  };
}
```

### 5. Host-Specific Module Lists

Hosts import different module subsets:

- Personal: Includes `opencode`, excludes some work tools
- Work: Different application set, same package base

### 6. Cross-Tool Integration via Package References

Tools reference each other's binaries:

```nix
# FZF uses bat for previews
"--preview '${pkgs.bat}/bin/bat {}'"

# FZF uses eza for directory trees
"--preview '${pkgs.eza}/bin/eza --tree {}'"
```

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: best-practices -->

## Best Practices

### Adding New Tools

1. **Check home-manager first**: Run `nix search nixpkgs <tool>` and check home-manager docs
2. **Create module directory**: `modules/home-manager/packages/<tool>/`
3. **Add default.nix**: Use standard template (see Conventions)
4. **Import in host**: Add to `sharedModules` in `hosts/personal/default.nix`
5. **Test**: Run `devenv shell -- switch`

### Cross-Tool Integration

When one tool depends on another:

```nix
{
  pkgs,
  ...
}:
{
  programs.fzf = {
    enable = true;
    fileWidgetOptions = [
      # Reference bat via pkgs, not hardcoded path
      "--preview '${pkgs.bat}/bin/bat --color=always {}'"
    ];
  };
}
```

### AI Tool Configuration

To add MCP servers or rules visible to all AI tools:

1. Edit `modules/home-manager/ai/mcp.nix` (servers)
2. Edit `modules/home-manager/ai/rules.nix` (instructions)
3. Edit `modules/home-manager/ai/agents.nix` (agent definitions)
4. Changes propagate to claude-code, opencode, and zed automatically

### Shell Aliases

Add to `modules/home-manager/packages/zsh/default.nix`:

```nix
shellAliases = {
  c = "clear";
  g = "${pkgs.git}/bin/git";
};
```

### Development Workflow

1. Make changes to Nix files
2. Run `format` to auto-format
3. Run `lint` to check for issues
4. Run `switch` to apply (triggers git hooks)
5. Hooks run treefmt, statix, shellcheck, flake-check

<!-- END AUTO-MANAGED -->

<!-- MANUAL -->

## Custom Notes

Add project-specific notes, tips, or reminders here. This section is never auto-modified.

<!-- END MANUAL -->
