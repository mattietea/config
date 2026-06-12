# Nix Dotfiles Configuration

Personal macOS system configuration using Nix Flakes, nix-darwin, and home-manager.

<!-- AUTO-MANAGED: project-description -->

## Overview

Declarative macOS dotfiles managing system settings, GUI applications, and CLI tools across two hosts (personal and work). Features modular architecture with 40+ tool configurations, independent AI tool setups, and integrated development environment via devenv.

**Key Features**:

- Modular tool configurations (each tool gets own `default.nix`)
- Two host configurations sharing a common app/package baseline (`lib/hosts.nix`) with inline per-host settings
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
update    # Update flake, devenv, and nvfetcher-pinned sources
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
- deadnix (dead code detection)
- shellcheck (shell script linting)
- flake-check (validate flake structure)

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: architecture -->

## Architecture

```
.
├── flake.nix                    # flake-parts based inputs and outputs
├── devenv.nix                   # Development environment & scripts
├── nvfetcher.toml               # Pinned non-flake sources (prebuilt CLIs, agent-skill repos)
├── _sources/                    # nvfetcher-generated pins (do not edit by hand)
├── overlays/
│   └── default.nix              # Packages built from nvfetcher sources (pup, linear-cli, wacli)
├── secrets/
│   ├── secrets.nix              # agenix recipients per secret
│   └── *.age                    # Encrypted secrets
├── .github/workflows/           # GitHub Actions CI
│   ├── check.yml                # Flake check + host evaluation (macOS runner) + devenv tests
│   └── update.yml               # Scheduled dependency updates (flake + devenv + nvfetcher)
├── lib/
│   ├── mkHost.nix               # Shared darwinSystem builder function
│   └── hosts.nix                # Shared app/package lists + helpers (app, pkg, trivialPkg)
├── hosts/
│   ├── personal.nix             # Personal host: settings + host-specific apps/packages
│   └── work.nix                 # Work host: settings + host-specific apps/packages
└── modules/
    ├── ai/                      # AI tool configuration
    │   ├── default.nix          # Aggregator: imports all base AI modules
    │   ├── work.nix             # Aggregator: imports work-specific AI overrides
    │   ├── personal.nix         # Aggregator: imports personal-specific AI overrides
    │   ├── harnesses/           # AI coding tools (claude-code, codex, opencode)
    │   ├── tools/               # ai.tools catalog: one toggle = skills + sources + instructions + packages
    │   ├── skills/              # Agent skills sources + targets
    │   ├── integrations/        # Harness integrations (claude-mem)
    │   ├── mcp/                 # MCP server configuration
    │   ├── plugins/             # Harness plugins (superpowers)
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
4. Each host file builds its app/package lists from the shared baseline in `lib/hosts.nix` (`commonApps`, `commonPackages`) plus host-specific additions
5. Host files call `lib/mkHost.nix` which handles all darwinSystem boilerplate
6. Each module configures a tool using home-manager or `home.packages`
7. AI tools use `enableMcpIntegration` to connect to shared MCP module

**Key Files**:

- `flake.nix` - flake-parts structure with `flake` and `perSystem` outputs, flake inputs
- `lib/mkHost.nix` - Shared darwinSystem builder (nixpkgs, home-manager, agenix, networking)
- `lib/hosts.nix` - Shared app/package baseline + `app`/`pkg`/`trivialPkg` helpers
- `hosts/personal.nix` - Personal host (settings + host-specific apps/packages)
- `hosts/work.nix` - Work host (settings + host-specific apps/packages + work secrets)
- `overlays/default.nix` - Custom packages built from nvfetcher sources (`pup`, `linear-cli`, `wacli`)
- `nvfetcher.toml` / `_sources/generated.nix` - Pinned non-flake sources (prebuilt CLIs, agent-skill repos)
- `devenv.nix` - Scripts (switch, format, lint, update, clean) and git hooks
- `modules/darwin/system/default.nix` - System defaults importer + meta settings
- `modules/darwin/system/dock.nix` - Dock, Spaces, Mission Control settings
- `modules/darwin/system/finder.nix` - Finder preferences
- `modules/darwin/system/input.nix` - Keyboard, trackpad, input settings
- `modules/darwin/system/updates.nix` - Software Update settings
- `modules/ai/mcp/default.nix` - MCP server configuration
- `modules/ai/default.nix` - AI module aggregator (imports harnesses, tools, skills, integrations, mcp, plugins, instructions)
- `modules/ai/tools/{default,catalog,work}.nix` - `ai.tools` catalog: one toggle registers a tool's skills, sources, instructions, and packages
- `modules/ai/harnesses/claude-code/default.nix` - Claude Code configuration
- `modules/ai/instructions/INSTRUCTIONS.md` - Global instruction file for all AI harnesses
- `.github/workflows/check.yml` - CI: flake check + evaluation of both darwin hosts (macOS runner) + devenv test
- `.github/workflows/update.yml` - Automated weekly dependency updates (flake + devenv + nvfetcher), auto-merged once checks pass

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

Shared app/package lists and helpers live in `lib/hosts.nix` (`commonApps`, `commonPackages`, `commonVariables`, plus the `app`/`pkg`/`trivialPkg` helpers). Each host file defines its settings inline, extends the shared baseline with host-specific entries, then calls `mkHost`:

```nix
# hosts/personal.nix
{ inputs }:
let
  inherit (import ../lib/hosts.nix)
    app
    trivialPkg
    commonApps
    commonPackages
    commonVariables
    ;

  settings = {
    username = "mattietea";
    name = "Matt Thomas";
    github = "mattietea";
    email = "mattcthomas@me.com";
    variables = commonVariables;
  };

  mkHost = import ../lib/mkHost.nix;
in
mkHost {
  inherit inputs settings;
  hostname = "Matts-Personal-Macbook-Air";
  applications = commonApps ++ map app [ "brave" "spotify" /* ... */ ];
  packages = commonPackages ++ map trivialPkg [ "wacli" ];
  ai = [
    ../modules/ai
    ../modules/ai/personal.nix
  ];
}
```

Use `trivialPkg "tool"` for tools that need no configuration beyond installing a single nixpkgs attribute — they get no module directory.

### Cross-Tool Integration

Reference other tools via full package path (`${pkgs.tool}/bin/tool`), including in shell aliases:

```nix
fileWidgetOptions = [ "--preview '${pkgs.bat}/bin/bat --color=always {}'" ];
shellAliases = { g = "${pkgs.git}/bin/git"; cat = "${pkgs.bat}/bin/bat"; };
```

### AI Tool Configuration

AI tools are consolidated under `modules/ai/` with a clear taxonomy:

- **harnesses/** — AI coding tools (claude-code, codex, opencode), each with `enableMcpIntegration = true`
- **tools/** — the `ai.tools` catalog; enabling one tool registers its skills, skill sources, instructions, and packages across every harness (base catalog in `catalog.nix`, work tools in `work.nix`)
- **skills/** — shared agent-skills sources + deploy targets (tool-specific sources live with their tool in `tools/`)
- **integrations/** — harness integrations (claude-mem)
- **mcp/** — MCP server configuration shared via `enableMcpIntegration`
- **plugins/** — harness plugins (superpowers)
- **instructions/** — Global instruction file deployed to Claude Code, Codex, and OpenCode

Host files import AI modules via aggregators:

```nix
ai = [
  ../modules/ai          # base (all harnesses, skills, mcp, instructions)
  ../modules/ai/work.nix # work-specific overrides
];
```

**Package sources**:

- claude-code: External flake input `claude-code-nix` (own binary cache)
- opencode: External flake input `llm-agents`

**Model configuration**:

- claude-code: `settings.model` using shorthand names (currently `"opus[1m]"`)
- opencode: Model ids centralized in `modules/ai/harnesses/opencode/models.nix`; per-agent assignments in `oh-my-openagent-base.nix` + per-host overrides

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
2. **No config needed?** Skip the module directory — add `"tool"` to the `trivialPkg` list in `lib/hosts.nix` (both hosts) or in a single host file (one host)
3. **Needs config?** Create `modules/home-manager/packages/<tool>/default.nix` using the standard template (see Conventions)
4. **Wire it up**: Add `"tool"` to the `pkg` list in `lib/hosts.nix` `commonPackages` (both hosts), or to `map pkg [ ... ]` in a single host file (one host)
5. **Test**: Run `devenv shell -- switch`

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
