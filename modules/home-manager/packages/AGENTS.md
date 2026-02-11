# CLI Tools & Packages Module

Collection of command-line tools and development utilities.

<!-- AUTO-MANAGED: module-description -->

## Purpose

Houses individual tool configurations for CLI utilities, development tools, and command-line applications. Each tool gets its own subdirectory with a `default.nix` module.

**Contains 25+ tools including**:

- Version control: git, gh, lazygit, git-absorb
- Shell & navigation: zsh, fzf, zoxide, eza
- Development: devenv, mise, node, bun
- Editor integration: bat, delta
- AI tools: claude-code, opencode

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: architecture -->

## Module Architecture

```
packages/
├── aerospace/       # Window manager
├── bat/             # Cat replacement with syntax highlighting
├── claude-code/     # AI coding assistant
├── devenv/          # Development environments
├── fzf/             # Fuzzy finder
├── git/             # Git configuration
├── mcp/             # MCP server configuration
├── zsh/             # Shell configuration
└── ... (25+ more)
```

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: conventions -->

## Module-Specific Conventions

See root `AGENTS.md` for standard module template, cross-tool integration, AI tool pattern, external package inputs, and hybrid bash+go build pattern.

### Settings Parameter

Tools needing user info receive `settings` via `specialArgs`:

```nix
{ pkgs, settings, ... }:
{
  programs.tool.config = settings.variables.EDITOR;
}
```

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: dependencies -->

## Key Dependencies

**Imported by**: `hosts/personal.nix` and `hosts/work.nix` as `sharedModules` paths

**Cross-package dependencies**:

- fzf -> bat, eza (preview integration)
- git -> delta (diff viewer)
- zsh -> multiple tools (shell integration)
- claude-code -> terminal-notifier (plugin dependencies)
- AI tools -> mcp (MCP server configuration via enableMcpIntegration)

<!-- END AUTO-MANAGED -->

<!-- MANUAL -->

## Custom Notes

Add module-specific notes here.

<!-- END MANUAL -->
