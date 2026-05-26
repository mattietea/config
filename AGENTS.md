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

<claude-mem-context>
# Memory Context

# [nix] recent context, 2026-05-26 7:42am EDT

Legend: 🎯session 🔴bugfix 🟣feature 🔄refactor ✅change 🔵discovery ⚖️decision 🚨security_alert 🔐security_note
Format: ID TIME TYPE TITLE
Fetch details: get_observations([IDs]) | Search: mem-search skill

Stats: 50 obs (20,155t read) | 254,153t work | 92% savings

### Apr 23, 2026

S2585 Code review of devenv→mise migration branch to assess whether removing devenv was the right decision (Apr 23 at 5:37 PM)

### Apr 29, 2026

S2586 Follow-up on devenv→mise migration reversibility and alternative approaches to address original pain points (Apr 29 at 7:01 PM)
S2587 Verified upstream zsh sigsuspend fix availability and determined if reverting devenv→mise migration is viable (Apr 29 at 7:16 PM)
3082 7:16p 🔵 Upstream zsh sigsuspend fix merged two days ago
3083 " 🔵 Current flake predates the zsh sigsuspend fix by 4 days
3084 7:17p 🔵 zsh sigsuspend fix is already in nixpkgs-unstable channel
S2588 Completed surgical revert of devenv→mise migration after confirming upstream zsh sigsuspend fix availability (Apr 29 at 7:17 PM)
3085 7:20p ✅ Started surgical revert of devenv→mise migration
3086 " ✅ Verified surgical revert correctly restores devenv infrastructure and removes workarounds
3087 7:21p ✅ Updated flake inputs to pull in zsh sigsuspend fix
3088 " ✅ Verified direnv builds with tests enabled after zsh sigsuspend fix
3089 " ✅ Validated personal host system configuration builds successfully
3090 7:22p 🔵 Dry-run reveals zsh-5.9 with sigsuspend fix will be deployed
3091 7:23p ✅ Work host dry-run validates successfully with zsh-5.9
S2589 Completed surgical revert of devenv→mise migration, committed changes, and prepared for deployment (Apr 29 at 7:23 PM)
3092 7:30p 🔵 Pre-commit hook still calls mise after revert, breaking git hooks
3093 7:31p 🔵 devenv command not available until system rebuild, blocking hook reinstallation
3094 7:33p ✅ Removed broken mise pre-commit hook to unblock commit
3095 " ✅ Committed surgical revert with comprehensive explanation
3096 7:34p ✅ Committed deletion of leftover mise migration files
S2590 Finalized surgical revert of devenv→mise migration, branch ready for deployment (Apr 29 at 7:34 PM)
S2591 Verification of deployed opencode configuration and investigation of model usage after nix configuration updates (Apr 29 at 7:36 PM)
3097 7:36p ✅ Pushed surgical revert commits to remote branch
3098 " 🔵 Net branch changes show only AI improvements after surgical revert
3099 7:37p ✅ Created PR #103 with auto-merge enabled for squash merge
S2592 Investigation: Why opencode sessions use different Claude models (opus-4-6 vs opus-4-7) despite Nix configuration specifying opus-4-7 (Apr 29 at 7:44 PM)
S3049 Resolve Home Manager 26.05 vs Nixpkgs 26.11 mismatch warning on matthewthomas profile (Apr 29 at 7:52 PM)

### May 26, 2026

5140 7:22a 🔵 Home Manager / Nixpkgs version mismatch warning surfaced
5141 " 🔵 Nix flake tracks nixpkgs-unstable while Home Manager input lags behind
5142 7:23a 🔵 Home Manager input pinned to master rev older than current nixpkgs-unstable
5143 " 🔵 mkHost central wiring confirms home-manager integration shape
5144 " ✅ Disabled Home Manager Nixpkgs release check in mkHost
5145 7:24a 🔵 nix flake check passes on dirty tree after enableNixpkgsReleaseCheck patch
5146 " 🔵 Upstream confirms no Home Manager release-26.11 branch yet; nixpkgs is mid-cutover
5147 7:25a 🔵 Home Manager FAQ recommends release-pinned input or unstable overlay pattern
5148 " ⚖️ Reverted release-check suppression and repinned flake to release-26.05 branches
5149 " ✅ Flake re-locking against nixpkgs-26.05-darwin and home-manager release-26.05
5150 " ✅ flake.lock re-locked to release-26.05 nixpkgs and home-manager
5151 7:26a 🔵 Home Manager release-check mechanism and post-repin alignment verified
5152 " 🔵 Post-fix verification: flake check passes and all release markers report 26.05
S3050 Resolve Home Manager 26.05 vs Nixpkgs 26.11 mismatch warning on matthewthomas profile by aligning inputs rather than suppressing the check (May 26 at 7:27 AM)
5153 7:31a 🔴 Ghostty zsh integration path stale in .zshrc
5154 " 🔵 Nix config repo has uncommitted flake changes
5155 7:32a 🔵 Ghostty zsh integration sourced via Home Manager initContent
5156 " 🔵 Ghostty 1.3.1 derivation split shell-integration into a separate store output
5157 7:34a 🔵 pkgs.ghostty-bin exposes shell_integration as a named output
5158 " 🔵 shell_integration output uses flat layout under zsh/, not share/ghostty
5159 " 🔵 Ghostty zsh integration features gated by GHOSTTY_SHELL_FEATURES
5160 7:35a 🔴 Switched Ghostty zsh integration source to $GHOSTTY_RESOURCES_DIR
5161 7:36a ✅ Verified Ghostty module diff and ran nix fmt
5162 " 🔵 Two darwin hosts both consume the Ghostty module
5163 7:37a 🔴 Verified rendered zshrc init now uses runtime $GHOSTTY_RESOURCES_DIR
5164 " 🔴 Personal host also renders fixed Ghostty source line
5165 7:38a 🔵 ~/.zshrc is a Home Manager symlink — requires switch to refresh
5166 " 🔄 Removed manual Ghostty zsh integration source block
5167 " ✅ Patch applied removing zsh initContent from Ghostty module
5168 7:39a ✅ Final Ghostty module diff confirms initContent removed
5169 " 🔴 Verified rendered zsh init no longer mentions Ghostty for either host
5170 7:40a 🔵 Working tree status after Ghostty fix
5171 " 🔵 Active ~/.zshrc still contains broken source line until activation

Access 254k tokens of past work via get_observations([IDs]) or mem-search skill.
</claude-mem-context>
