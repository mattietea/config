# CLI Tools & Packages Module

Collection of command-line tools and development utilities.

<!-- AUTO-MANAGED: module-description -->

## Purpose

Houses individual tool configurations for CLI utilities, development tools, and command-line applications. Each tool gets its own subdirectory with a `default.nix` module that configures it using home-manager when available, or falls back to `home.packages`.

**Contains 30+ tools including**:

- Version control: git, gh, lazygit, git-absorb, graphite
- Shell & navigation: zsh, fzf, zoxide, eza
- Development: devenv, mise, node, bun, pnpm
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
│   ├── default.nix
│   └── utilities.nix
├── devenv/          # Development environments
├── fzf/             # Fuzzy finder
├── git/             # Git configuration
├── zsh/             # Shell configuration
└── ... (30+ more)
```

**Module Pattern**:

- Each directory has `default.nix`
- Some have `utilities.nix` for helper functions (e.g., AI tools)
- Imported by hosts via relative paths in `sharedModules`

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: conventions -->

## Module-Specific Conventions

### Standard Module Structure

**With home-manager support** (preferred):

```nix
{
  pkgs,
  ...
}:
{
  programs.tool = {
    enable = true;
    enableZshIntegration = true;  # if available
    # tool-specific config
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

### Cross-Package References

Reference other packages via `${pkgs.tool}/bin/tool`:

```nix
# fzf/default.nix references bat and eza
fileWidgetOptions = [
  "--preview '${pkgs.bat}/bin/bat --color=always {}'"
];
changeDirWidgetOptions = [
  "--preview '${pkgs.eza}/bin/eza --tree {}'"
];
```

### AI Tool Pattern

AI tools (claude-code, opencode) follow special pattern:

```nix
let
  utils = import ./utilities.nix { inherit lib; };
  ai = import ../../ai;
in
{
  home.packages = [ /* dependencies */ ];
  programs.tool = {
    enable = true;
    inherit (utils) mcpServers;
    memory.text = ai.rules;
    inherit (ai) agents;
  };
}
```

### Settings Parameter

Tools needing user info receive `settings` parameter:

```nix
{
  pkgs,
  settings,  # Passed via specialArgs
  ...
}:
{
  programs.tool = {
    enable = true;
    config = settings.variables.EDITOR;
  };
}
```

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: dependencies -->

## Key Dependencies

**Imports from**:

- `modules/home-manager/ai/` - Shared AI configuration (claude-code, opencode)
- Host `settings` via `specialArgs` - User info, environment variables

**Imported by**:

- `hosts/personal/default.nix` - As `sharedModules` paths
- `hosts/work/default.nix` - As `sharedModules` paths

**Cross-package dependencies**:

- fzf → bat, eza (preview integration)
- git → delta (diff viewer)
- zsh → multiple tools (shell integration)
- claude-code → terminal-notifier, python3 (plugin dependencies)

<!-- END AUTO-MANAGED -->

<!-- MANUAL -->

## Custom Notes

Add module-specific notes here.

<!-- END MANUAL -->
