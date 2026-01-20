# Nix Dotfiles Configuration

Personal macOS system configuration using Nix Flakes, nix-darwin, and home-manager.

<!-- AUTO-MANAGED: project-description -->

## Overview

Declarative macOS dotfiles managing system settings, GUI applications, and CLI tools across two hosts (personal and work). Features modular architecture with 45+ tool configurations, shared AI tooling setup with Sisyphus multi-agent orchestration, and integrated development environment via devenv.

**Key Features**:

- Modular tool configurations (each tool gets own `default.nix`)
- Two host configurations with shared modules
- Unified AI tool configuration (claude-code, opencode, zed) with Sisyphus orchestration mode
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

**System updates**:

```bash
# Update Nix itself (outside devenv shell)
sudo determinate-nixd upgrade
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
├── flake.nix                    # flake-parts based inputs and outputs
├── devenv.nix                   # Development environment & scripts
├── .claude/auto-memory/         # Auto-memory plugin cache (gitignored)
├── lib/
│   ├── settings.nix             # Shared user settings (username, email, etc.)
│   └── modules.nix              # Shared module lists with path resolution
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

1. `flake.nix` uses flake-parts for modular structure
2. `lib/settings.nix` provides shared user config to all hosts
3. `lib/modules.nix` provides shared module lists with path resolution
4. `hosts/{personal,work}/default.nix` import from lib/ and use `sharedModules`
5. Each module configures a tool using home-manager or `home.packages`
6. AI tools import shared config from `modules/home-manager/ai/`

**Key Files**:

- `flake.nix` - flake-parts based (nixpkgs, darwin, home-manager, flake-parts)
- `lib/settings.nix` - Single source of truth for user settings
- `lib/modules.nix` - Shared module lists (DRY host configuration)
- `devenv.nix` - Scripts (switch, format, lint, update) and git hooks
- `hosts/*/default.nix` - Minimal host-specific config (just hostname)
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
# Host imports from lib/ (DRY pattern)
let
  settings = import ../../lib/settings.nix;
  modules = import ../../lib/modules.nix { root = ../..; };
in
{
  sharedModules = modules.all;  # or modules.allBase for subset
}

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
- Rules/instructions from `modules/home-manager/ai/rules.nix` (includes Sisyphus orchestration mode)
- Agent definitions from `modules/home-manager/ai/agents.nix`

Each tool has `utilities.nix` to transform shared config to tool-specific format.

**Sisyphus orchestration mode** is enabled by default, providing 11 specialized agents (sisyphus-junior, prometheus, oracle, metis, momus, explore, frontend-engineer, document-writer, qa-tester, librarian, multimodal-looker) for multi-agent coordination via the Task tool.

**Model configuration**:

- claude-code: Top-level `settings.model` using shorthand names (`"opus"`, `"sonnet"`, `"haiku"`)
- opencode: Per-agent models in `oh-my-opencode.json` (e.g., `agents.Sisyphus.model = "anthropic/claude-opus-4-5"`)

### Claude Code Plugin Configuration

Claude Code plugins configured in `modules/home-manager/packages/claude-code/default.nix`:

**Plugin naming convention**: `plugin-name@marketplace-name` format in `enabledPlugins`

**Enabled plugins**:

- `oh-my-claude-sisyphus@oh-my-claude-sisyphus` - Advanced orchestration and planning
- `auto-memory@severity1-marketplace` - Automatic CLAUDE.md/AGENTS.md management
- `code-simplifier@claude-plugins-official` - Code optimization suggestions
- `claude-notifications-go@claude-notifications-go` - macOS desktop notifications

**Required package dependencies**:

- `terminal-notifier` - macOS notification support for claude-notifications-go
- `python3` - Python runtime for auto-memory plugin

**Plugin marketplaces**: Defined in `extraKnownMarketplaces` with GitHub source repositories

### Claude Code Status Line

Custom colorized status line using ANSI color codes in `statusLine.command`:

```nix
statusLine = {
  type = "command";
  command = ''
    # ANSI color codes
    CYAN='\033[0;36m'
    YELLOW='\033[0;33m'
    PINK='\033[0;35m'
    RESET='\033[0m'

    dir=$(pwd | sed "s|^$HOME|~|")
    branch=$(git branch --show-current 2>/dev/null)
    dirty=""
    [ -n "$(git status --porcelain 2>/dev/null)" ] && dirty="''${PINK}*''${RESET}"
    usage=$(cat | ${pkgs.bun}/bin/bun x ccusage statusline 2>/dev/null)

    printf "%b%s%b %b%s%b%b %b\n" "''${CYAN}" "$dir" "''${RESET}" "''${YELLOW}" "$branch" "''${RESET}" "$dirty" "$usage"
  '';
};
```

**Color scheme**: Cyan for directory, yellow for git branch, pink asterisk for dirty status, usage statistics

**Implementation details**: Uses `printf` with format strings for precise formatting control, avoiding shell interpretation issues with `echo -e`. Dirty status shown as separate pink asterisk instead of appending to branch name.

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

### 5. Shared Module Lists (DRY Pattern)

Hosts import from `lib/modules.nix` for DRY configuration:

```nix
let
  modules = import ../../lib/modules.nix { root = ../..; };
in
{
  sharedModules = modules.all;  # All modules (base + extras)
}
```

Module lists in `lib/modules.nix`:

- `allBase` - Core apps + packages (raycast, zed, all CLI tools)
- `allExtras` - Extra apps (brave, safari, discord, spotify, docker)
- `all` - Everything (allBase + allExtras)

### 6. Cross-Tool Integration via Package References

Tools reference each other's binaries:

```nix
# FZF uses bat for previews
"--preview '${pkgs.bat}/bin/bat {}'"

# FZF uses eza for directory trees
"--preview '${pkgs.eza}/bin/eza --tree {}'"
```

### 7. Shell Aliases with Package References

Shell aliases reference packages via `${pkgs.tool}/bin/tool`:

```nix
# zsh/default.nix
shellAliases = {
  g = "${pkgs.git}/bin/git";
  cat = "${pkgs.bat}/bin/bat";
  code = "${settings.variables.VISUAL}";
  claude = "claude --dangerously-skip-permissions";
};
```

### 8. Command-Based Dynamic Configuration

Tools can use shell commands for dynamic runtime configuration:

```nix
# claude-code/default.nix - Colorized status line
statusLine = {
  type = "command";
  command = ''
    # ANSI color codes
    CYAN='\033[0;36m'
    YELLOW='\033[0;33m'
    PINK='\033[0;35m'
    RESET='\033[0m'

    dir=$(pwd | sed "s|^$HOME|~|")
    branch=$(git branch --show-current 2>/dev/null)
    dirty=""
    [ -n "$(git status --porcelain 2>/dev/null)" ] && dirty="''${PINK}*''${RESET}"
    usage=$(cat | ${pkgs.bun}/bin/bun x ccusage statusline 2>/dev/null)

    printf "%b%s%b %b%s%b%b %b\n" "''${CYAN}" "$dir" "''${RESET}" "''${YELLOW}" "$branch" "''${RESET}" "$dirty" "$usage"
  '';
};
```

Pattern: Use double-single-quote (`''`) for multi-line strings, reference packages via `${pkgs.tool}/bin/tool`, prefer `printf` over `echo -e` for ANSI color formatting

### 9. Non-Flake Input Pattern (External Packages)

For packages not in nixpkgs that need to be built from source:

```nix
# flake.nix - Add as non-flake input
mole-src = {
  url = "github:tw93/Mole";
  flake = false;  # Just fetch source, don't evaluate as flake
};
```

Access in modules via `inputs.mole-src`. Use `inputs.mole-src.shortRev` for version.

### 10. Hybrid Bash + Go Package Pattern

For packages with mixed bash scripts and Go binaries (e.g., mole):

```nix
# Two-stage build pattern
let
  # Stage 1: Build Go binaries
  go-helpers = pkgs.buildGoModule {
    pname = "tool-go-helpers";
    src = inputs.tool-src;
    proxyVendor = true;  # Bypass out-of-sync vendor directories
    overrideModAttrs = _: {
      modPostBuild = "go mod tidy";  # Sync dependencies
    };
    vendorHash = "sha256-...";
  };

  # Stage 2: Assemble final package
  tool = pkgs.stdenv.mkDerivation {
    pname = "tool";
    src = inputs.tool-src;
    dontBuild = true;  # Skip build, just install
    installPhase = ''
      mkdir -p $out/libexec $out/bin
      cp -r bin lib $out/libexec/
      cp ${go-helpers}/bin/* $out/libexec/bin/
      substitute main-script $out/bin/tool \
        --replace 'SCRIPT_DIR="$(cd "$(dirname "''${BASH_SOURCE[0]}")" && pwd)"' \
                  "SCRIPT_DIR='$out/libexec'"
    '';
  };
in
```

**Key patterns**:

- `proxyVendor = true` - Bypass upstream's out-of-sync vendor directory
- `modPostBuild = "go mod tidy"` - Fix dependency mismatches
- `dontBuild = true` - Skip build phase for script-only packages
- `$out/libexec/` - Internal binaries/scripts, `$out/bin/` - User-facing commands
- `substitute` - Patch hardcoded paths in bash scripts

### 11. Mac App Store Integration Pattern

For installing macOS App Store apps declaratively via `mas` CLI:

```nix
{
  pkgs,
  lib,
  ...
}:
let
  masApps = {
    "App Name" = 1234567890;  # App Store ID
  };
in
{
  home.packages = [ pkgs.mas ];

  home.activation.installMasApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: id: ''
        if ! ${pkgs.mas}/bin/mas list | grep -q "^${toString id} "; then
          echo "Installing ${name}..."
          ${pkgs.mas}/bin/mas install ${toString id}
        fi
      '') masApps
    )}
  '';
}
```

**Key patterns**:

- `masApps` attrset maps display names to App Store IDs
- `home.activation` runs during `switch` for imperative actions
- `lib.hm.dag.entryAfter [ "writeBoundary" ]` ensures proper ordering
- Idempotent: checks if already installed before running `mas install`
- Find App Store IDs via `mas search <app-name>` or App Store URLs

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: best-practices -->

## Best Practices

### Adding New Tools

1. **Check home-manager first**: Run `nix search nixpkgs <tool>` and check home-manager docs
2. **Create module directory**: `modules/home-manager/packages/<tool>/`
3. **Add default.nix**: Use standard template (see Conventions)
4. **Add to lib/modules.nix**: Add `(pkg "tool-name")` to the appropriate list
5. **Test**: Run `devenv shell -- switch`

Note: Adding to `lib/modules.nix` automatically enables for all hosts using that module list.

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
