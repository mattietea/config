# Nix Dotfiles Configuration

Personal macOS system configuration using Nix Flakes, nix-darwin, and home-manager.

<!-- AUTO-MANAGED: project-description -->

## Overview

Declarative macOS dotfiles managing system settings, GUI applications, and CLI tools across two hosts (personal and work). Features modular architecture with 40+ tool configurations, independent AI tool setups, and integrated development environment via devenv.

**Key Features**:

- Modular tool configurations (each tool gets own `default.nix`)
- Two self-contained host configurations with inline settings
- Independent AI tool configuration (claude-code, opencode, zed) with MCP integration
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
├── .github/workflows/           # GitHub Actions CI
│   ├── check.yml                # Flake validation and devenv tests
│   └── update.yml               # Scheduled dependency updates (flake + devenv)
├── lib/
│   └── mkHost.nix               # Shared darwinSystem builder function
├── hosts/
│   ├── personal.nix             # Self-contained personal config (settings + apps + packages)
│   └── work.nix                 # Self-contained work config (settings + apps + packages)
└── modules/
    ├── ai/                      # AI tool configuration
    │   ├── default.nix          # Aggregator: imports all base AI modules
    │   ├── work.nix             # Aggregator: imports work-specific AI overrides
    │   ├── personal.nix         # Aggregator: imports personal-specific AI overrides
    │   ├── harnesses/           # AI coding tools (claude-code, opencode)
    │   ├── skills/              # Agent skills configuration
    │   ├── mcp/                 # MCP server configuration
    │   └── instructions/        # Global instruction file (INSTRUCTIONS.md)
    ├── darwin/system/           # macOS system defaults
    │   ├── default.nix          # Importer + meta settings
    │   ├── dock.nix             # Dock, Spaces, Mission Control
    │   ├── finder.nix           # Finder preferences
    │   ├── input.nix            # Keyboard, trackpad, input settings
    │   └── updates.nix          # Software Update settings
    └── home-manager/
        ├── applications/        # GUI apps (brave, zed, discord, etc.)
        │   └── */default.nix
        └── packages/            # CLI tools (git, fzf, zsh, etc.)
            └── */default.nix
```

**Data Flow**:

1. `flake.nix` uses `flake-parts.lib.mkFlake` for modular flake structure
2. `flake.nix` imports `hosts/personal.nix` and `hosts/work.nix` directly
3. Each host file defines its own settings (username, email, env vars) inline
4. Each host file lists its own applications and packages explicitly
5. Host files call `lib/mkHost.nix` which handles all darwinSystem boilerplate
6. Each module configures a tool using home-manager or `home.packages`
7. AI tools use `enableMcpIntegration` to connect to shared MCP module

**Key Files**:

- `flake.nix` - flake-parts structure with `flake` and `perSystem` outputs, flake inputs
- `lib/mkHost.nix` - Shared darwinSystem builder (nixpkgs, home-manager, networking)
- `hosts/personal.nix` - Self-contained personal host (settings, apps, packages)
- `hosts/work.nix` - Self-contained work host (settings, apps, packages)
- `devenv.nix` - Scripts (switch, format, lint, update, clean) and git hooks
- `modules/darwin/system/default.nix` - System defaults importer + meta settings
- `modules/darwin/system/dock.nix` - Dock, Spaces, Mission Control settings
- `modules/darwin/system/finder.nix` - Finder preferences
- `modules/darwin/system/input.nix` - Keyboard, trackpad, input settings
- `modules/darwin/system/updates.nix` - Software Update settings
- `modules/ai/mcp/default.nix` - MCP server configuration
- `modules/ai/default.nix` - AI module aggregator (imports harnesses, skills, mcp, instructions)
- `modules/ai/harnesses/claude-code/default.nix` - Claude Code configuration
- `modules/ai/instructions/INSTRUCTIONS.md` - Global instruction file for all AI harnesses
- `.github/workflows/check.yml` - CI: flake check + devenv test
- `.github/workflows/update.yml` - Automated weekly dependency updates (flake + devenv)

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: conventions -->

## Code Conventions

### Module Structure

**Standard module template** (prefer `programs.*` over `home.packages`):

```nix
{
  pkgs,
  ...
}:
{
  programs.tool = {
    enable = true;
    enableZshIntegration = true;  # if available
  };
}
```

**Without home-manager support**: `home.packages = [ pkgs.tool ];`

### Naming Conventions

- Module directories: `lowercase-with-dashes` (e.g., `git-absorb/`)
- Module files: Always `default.nix`
- Host files: `hosts/<name>.nix` (single file per host)
- Settings: Defined inline in each host file

### Host Configuration Pattern

Each host is a self-contained file that defines settings, apps, and packages, then calls `mkHost`:

```nix
# hosts/personal.nix
{ inputs }:
let
  settings = {
    username = "mattietea";
    email = "mattcthomas@me.com";
    variables = { EDITOR = "zed --wait"; VISUAL = "zed --wait"; };
  };
  mkHost = import ../lib/mkHost.nix;
  app = name: ../modules/home-manager/applications/${name};
  pkg = name: ../modules/home-manager/packages/${name};
in
mkHost {
  inherit inputs settings;
  hostname = "Matts-Personal-Macbook-Air";
  applications = [ (app "brave") (app "zed") /* ... */ ];
  packages = [ (pkg "git") (pkg "fzf") /* ... */ ];
  ai = [
    ../modules/ai
    ../modules/ai/personal.nix
  ];
}
```

### Cross-Tool Integration

Reference other tools via full package path (`${pkgs.tool}/bin/tool`), including in shell aliases:

```nix
fileWidgetOptions = [ "--preview '${pkgs.bat}/bin/bat --color=always {}'" ];
shellAliases = { g = "${pkgs.git}/bin/git"; cat = "${pkgs.bat}/bin/bat"; };
```

### AI Tool Configuration

AI tools are consolidated under `modules/ai/` with a clear taxonomy:

- **harnesses/** — AI coding tools (claude-code, opencode), each with `enableMcpIntegration = true`
- **skills/** — Agent skills shared across harnesses
- **mcp/** — MCP server configuration shared via `enableMcpIntegration`
- **instructions/** — Global instruction file deployed to Claude Code, Codex, and OpenCode

Host files import AI modules via aggregators:

```nix
ai = [
  ../modules/ai          # base (all harnesses, skills, mcp, instructions)
  ../modules/ai/work.nix # work-specific overrides
];
```

**Package sources**:

- claude-code, opencode: External flake input `llm-agents`

**Model configuration**:

- claude-code: `settings.model` using shorthand names (currently `"opus[1m]"`)
- opencode: Per-agent models in `oh-my-opencode.json`

### External Package Inputs

**Pre-built packages from other flakes**:

```nix
# flake.nix
llm-agents.url = "github:numtide/llm-agents.nix";
```

Access in modules via `inputs.llm-agents.packages.${pkgs.system}.claude-code`.

**Source-only packages** (build yourself): Use `flake = false` input, access via `inputs.tool-src`.

### Hybrid Bash + Go Build Pattern

Two-stage build for packages with bash scripts + Go binaries:

1. **Stage 1**: `pkgs.buildGoModule` for Go binaries (`proxyVendor = true` for out-of-sync vendor, `modPostBuild = "go mod tidy"` for dependency mismatches)
2. **Stage 2**: `pkgs.stdenv.mkDerivation` with `dontBuild = true` to assemble scripts + Go binaries, using `substitute` to patch hardcoded paths

Key dirs: `$out/libexec/` for internal binaries, `$out/bin/` for user-facing commands.

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: best-practices -->

## Best Practices

### Adding New Tools

1. **Check home-manager first**: Run `nix search nixpkgs <tool>` and check home-manager docs
2. **Create module directory**: `modules/home-manager/packages/<tool>/`
3. **Add default.nix**: Use standard template (see Conventions)
4. **Add to host files**: Add `(pkg "tool-name")` to each host that should have it (`hosts/personal.nix`, `hosts/work.nix`)
5. **Test**: Run `devenv shell -- switch`

Note: Each host independently lists its packages — adding to one host does not affect the other.

### MCP Server Configuration

To add MCP servers for AI tools:

1. Edit `modules/ai/mcp/default.nix`
2. Add server to `programs.mcp.servers` attribute set
3. Changes available to all tools with `enableMcpIntegration = true`

### Development Workflow

1. Make changes to Nix files
2. Run `format` to auto-format
3. Run `lint` to check for issues
4. Run `switch` to apply (triggers git hooks)
5. Hooks run treefmt, statix, shellcheck, flake-check

<!-- END AUTO-MANAGED -->

<!-- MANUAL -->

## Custom Notes

**Always invoke Nix skills before writing/modifying Nix code:**

- `/home-manager` — When adding tools, configuring apps, setting up shell integrations, managing cross-tool references
- `/nix` — When writing or reviewing any Nix code (patterns, anti-patterns, formatting, lib access)
- `/nix-darwin` — When modifying macOS system defaults, flake inputs, host files, or mkHost builder

<!-- END MANUAL -->
