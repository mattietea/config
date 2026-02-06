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
├── .sisyphus/                   # Sisyphus planning artifacts (gitignored)
├── .github/workflows/           # GitHub Actions CI
│   ├── check.yml                # Flake validation and devenv tests
│   └── update.yml               # Scheduled dependency updates (flake + devenv)
├── lib/
│   └── mkHost.nix               # Shared darwinSystem builder function
├── hosts/
│   ├── personal.nix             # Self-contained personal config (settings + apps + packages)
│   └── work.nix                 # Self-contained work config (settings + apps + packages)
└── modules/
    ├── darwin/system/           # macOS system defaults
    └── home-manager/
        ├── applications/        # GUI apps (brave, zed, discord, etc.)
        │   └── */default.nix
        └── packages/            # CLI tools (git, fzf, zsh, etc.)
            ├── mcp/             # Standalone MCP server configuration
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
- `modules/home-manager/packages/mcp/default.nix` - MCP server configuration
- `.github/workflows/check.yml` - CI: flake check + devenv test
- `.github/workflows/update.yml` - Automated weekly dependency updates (flake + devenv)

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

### Devenv Configuration

**Git hooks setup**:

```nix
git-hooks = {
  enable = true;
  package = pkgs.pre-commit;  # Explicit package for pre-commit
  hooks = {
    treefmt.enable = true;
    statix.enable = true;
    shellcheck.enable = true;
    flake-check = {
      enable = true;
      entry = "nix flake check --no-build";
      pass_filenames = false;
    };
  };
};
```

Convention: Explicitly set `package = pkgs.pre-commit` to ensure correct pre-commit binary is used

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
}
```

### Cross-Tool Integration

Reference other tools via full package path:

```nix
fileWidgetOptions = [
  "--preview '${pkgs.bat}/bin/bat --color=always {}'"
];
```

### AI Tool Configuration

AI tools (claude-code, opencode, zed) configure independently:

- Each tool uses `enableMcpIntegration = true` to connect to shared MCP module
- MCP servers defined in `modules/home-manager/packages/mcp/default.nix`
- No shared rules or agent definitions - tools configure their own settings

**Package sources**:

- claude-code: Uses external flake input `claude-code-nix` for pre-built package
- opencode, zed: Use nixpkgs packages

**Model configuration**:

- claude-code: Top-level `settings.model` using shorthand names (`"opus"`, `"sonnet"`, `"haiku"`)
- opencode: Per-agent models in `oh-my-opencode.json` (e.g., `agents.Sisyphus.model = "anthropic/claude-opus-4-5"`)

**MCP Integration**: Use `programs.mcp.servers` in mcp module, all AI tools access via `enableMcpIntegration`

### Claude Code Configuration

Claude Code configured in `modules/home-manager/packages/claude-code/default.nix`:

**Core settings**:

- Model: `"opus"` (shorthand: opus, sonnet, haiku)
- Default mode: `"plan"`
- Package source: `inputs.claude-code-nix` (external flake)
- MCP integration: `enableMcpIntegration = true`

**UI settings**:

- Theme: `"dark"`
- Terminal progress bar: `true`
- Show tips: `true`
- Verbose output: `true`
- Output style: `"default"`
- Show code diff footer: `true`
- Editor mode: `"normal"`

**Feature settings**:

- Auto-compact: `true`
- Thinking mode: `true`
- Prompt suggestions: `true`
- Rewind code: `true`
- Respect gitignore in file picker: `true`
- Always show bash output: `true`

**Notifications**: Ghostty OSC 777 protocol (`notifications = "ghostty"`)

**IDE integration**:

- Auto-connect IDE: `true`
- Claude in Chrome enabled by default: `true`

**Plugins**:

- `oh-my-claudecode@omc` - Advanced orchestration and planning
- `code-simplifier@claude-plugins-official` - Code optimization suggestions
- `claude-notifications-go@claude-notifications-go` - macOS desktop notifications

**Plugin naming convention**: `plugin-name@marketplace-name` format in `enabledPlugins`

**Required package dependencies**:

- `terminal-notifier` - macOS notification support for claude-notifications-go

**Plugin marketplaces**: Defined in `extraKnownMarketplaces` with GitHub source repositories

**Permissions**: Comprehensive allow list (Read, Edit, Write, Glob, Grep, Task, WebFetch, WebSearch, Bash commands for git/npm/python/cargo/go/make/jq/gh) with deny list for sensitive files (.env, secrets, SSH keys)

### Claude Code Status Line

Claude Code uses oh-my-claudecode HUD for status line:

```nix
statusLine = {
  type = "command";
  command = "node ~/.claude/hud/omc-hud.mjs";
};
```

**Implementation**: Delegates to oh-my-claudecode plugin's HUD module for dynamic status display

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

### 4. MCP Integration Pattern

AI tools use independent configuration with shared MCP:

```nix
{
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      model = "opus";
      # ... tool-specific settings
    };
  };
}
```

### 5. Self-Contained Host Files

Each host file is fully independent — settings, apps, and packages all in one place:

- `hosts/personal.nix` - Personal MacBook Air (includes brave, safari, discord)
- `hosts/work.nix` - Work MacBook Pro (base apps only)

Both call `lib/mkHost.nix` which handles darwinSystem boilerplate. Package lists are intentionally duplicated so hosts are independent.

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
# claude-code/default.nix - oh-my-claudecode HUD
statusLine = {
  type = "command";
  command = "node ~/.claude/hud/omc-hud.mjs";
};
```

Pattern: Use `type = "command"` for dynamic status displays. Delegate to external scripts for complex processing.

### 9. External Package Inputs Pattern

**For pre-built packages from other flakes**:

```nix
# flake.nix - Add as flake input
claude-code-nix.url = "github:sadjow/claude-code-nix";
claude-code-nix.inputs.nixpkgs.follows = "nixpkgs";
```

**Access in modules**:

```nix
{
  inputs,
  pkgs,
  ...
}:
{
  programs.claude-code = {
    enable = true;
    package = inputs.claude-code-nix.packages.${pkgs.system}.default;
  };
}
```

**For source-only packages (build yourself)**:

```nix
# flake.nix - Add as non-flake input
tool-src = {
  url = "github:org/tool";
  flake = false;  # Just fetch source, don't evaluate as flake
};
```

Access in modules via `inputs.tool-src`. Use `inputs.tool-src.shortRev` for version.

### 10. Hybrid Bash + Go Package Pattern

For packages with mixed bash scripts and Go binaries:

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
    subPackages = [ "cmd/helper1" "cmd/helper2" ];
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
- `subPackages` - List Go subpackages to build

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

### 12. flake-parts Modular Flake Pattern

For maintainable flake structure using flake-parts:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # External package flakes
    claude-code-nix.url = "github:sadjow/claude-code-nix";
    claude-code-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" ];

      flake = {
        # Top-level flake outputs (darwinConfigurations, etc.)
        darwinConfigurations = {
          Matts-Work-MacBook-Pro = import ./hosts/work.nix { inherit inputs; };
          Matts-Personal-Macbook-Air = import ./hosts/personal.nix { inherit inputs; };
        };
      };

      perSystem = { pkgs, ... }: {
        # Per-system outputs (formatter, devShells, etc.)
        formatter = pkgs.nixfmt;
      };
    };
}
```

**Benefits**:

- Modular structure separates flake-level and per-system outputs
- Automatic system iteration via `perSystem`
- Cleaner than manual `forAllSystems` pattern
- `flake.darwinConfigurations` for system configs, `perSystem.formatter` for dev tools
- Use `inputs.nixpkgs.follows` to unify dependency versions across all inputs

### 13. mkHost Builder Pattern

Extract darwinSystem boilerplate into a reusable builder function:

```nix
# lib/mkHost.nix - Shared builder
{
  inputs, settings, hostname,
  system ? "aarch64-darwin",
  applications ? [ ], packages ? [ ],
}:
inputs.darwin.lib.darwinSystem {
  inherit system;
  specialArgs = { inherit inputs settings; };
  modules = [
    { nixpkgs.config.allowUnfree = true; nix.enable = false; /* ... */ }
    ../modules/darwin/system
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager = {
        sharedModules = applications ++ packages;
        users.${settings.username} = { /* ... */ };
      };
    }
    { networking.hostName = hostname; }
  ];
}
```

**Pattern**:

- Builder takes `{ inputs, settings, hostname, applications, packages }`
- Settings defined inline in each host file (not shared)
- Each host independently lists its apps and packages
- Settings passed via `specialArgs` and `extraSpecialArgs` for system and home-manager access

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

### MCP Server Configuration

To add MCP servers for AI tools:

1. Edit `modules/home-manager/packages/mcp/default.nix`
2. Add server to `programs.mcp.servers` attribute set
3. Changes available to all tools with `enableMcpIntegration = true`

Example:

```nix
programs.mcp.servers = {
  new-server = {
    type = "stdio";
    command = "npx";
    args = [ "-y" "@scope/package" ];
  };
};
```

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
