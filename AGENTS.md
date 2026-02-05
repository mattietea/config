# Nix Dotfiles Configuration

Personal macOS system configuration using Nix Flakes, nix-darwin, and home-manager.

<!-- AUTO-MANAGED: project-description -->

## Overview

Declarative macOS dotfiles managing system settings, GUI applications, and CLI tools across two hosts (personal and work). Features modular architecture with 40+ tool configurations, independent AI tool setups, and integrated development environment via devenv.

**Key Features**:

- Modular tool configurations (each tool gets own `default.nix`)
- Two host configurations with shared modules
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
├── .claude/auto-memory/         # Auto-memory plugin cache (gitignored)
├── .sisyphus/                   # Sisyphus planning artifacts (gitignored)
├── .github/workflows/           # GitHub Actions CI
│   ├── check.yml                # Flake validation and devenv tests
│   └── update.yml               # Scheduled dependency updates (flake + devenv)
├── lib/
│   ├── settings/default.nix     # Shared user settings (username, email, env vars)
│   └── modules/default.nix      # Shared module lists with path resolution
├── hosts/
│   ├── personal/default.nix     # Personal MacBook Air config
│   └── work/default.nix         # Work MacBook Pro config
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
2. `flake.nix` includes `claude-code-nix` flake input for pre-built claude-code package
3. `lib/settings/default.nix` provides shared user config to all hosts
4. `lib/modules/default.nix` accepts `{ root }` parameter for path resolution
5. `hosts/{personal,work}/default.nix` import from lib/ with `modules.allPersonal` or `modules.allWork`
6. Each module configures a tool using home-manager or `home.packages`
7. AI tools use `enableMcpIntegration` to connect to shared MCP module

**Key Files**:

- `flake.nix` - flake-parts structure with `flake` and `perSystem` outputs, flake inputs
- `lib/settings/default.nix` - Single source of truth for user settings
- `lib/modules/default.nix` - Shared module lists (DRY host configuration)
- `devenv.nix` - Scripts (switch, format, lint, update, clean) and git hooks
- `hosts/*/default.nix` - Minimal host-specific config (hostname + module list selection)
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
- Files: Always `default.nix`
- Settings parameter: Passed via `specialArgs` in host config

### Import Patterns

```nix
# Host imports from lib/ (DRY pattern)
let
  settings = import ../../lib/settings;
  modules = import ../../lib/modules { root = ../..; };
in
inputs.darwin.lib.darwinSystem {
  specialArgs = { inherit inputs settings; };
  modules = [
    {
      users.users.${settings.username} = { ... };
    }
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager = {
        extraSpecialArgs = { inherit settings inputs; };
        sharedModules = modules.allPersonal;  # or modules.allWork
      };
    }
  ];
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

### Claude Code Plugin Configuration

Claude Code plugins configured in `modules/home-manager/packages/claude-code/default.nix`:

**Plugin naming convention**: `plugin-name@marketplace-name` format in `enabledPlugins`

**Enabled plugins**:

- `oh-my-claudecode@oh-my-claudecode` - Advanced orchestration and planning
- `auto-memory@severity1-marketplace` - Automatic CLAUDE.md/AGENTS.md management
- `code-simplifier@claude-plugins-official` - Code optimization suggestions
- `claude-notifications-go@claude-notifications-go` - macOS desktop notifications

**Required package dependencies**:

- `terminal-notifier` - macOS notification support for claude-notifications-go
- `python3` - Python runtime for auto-memory plugin

**Plugin marketplaces**: Defined in `extraKnownMarketplaces` with GitHub source repositories

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

### 5. Shared Module Lists (DRY Pattern)

Hosts import from `lib/modules/default.nix` for DRY configuration:

```nix
let
  modules = import ../../lib/modules { root = ../..; };
in
{
  home-manager.sharedModules = modules.allPersonal;  # or modules.allWork
}
```

Module lists in `lib/modules/default.nix`:

- `allBase` - Core apps (raycast, zed, spotify, docker) + all packages
- `allPersonal` - allBase + personal apps (brave, safari, discord)
- `allWork` - allBase only (no personal-specific apps)

Path resolution via `{ root }` function parameter ensures correct relative paths from any importer.

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

Pattern: Delegate to external scripts for complex dynamic status displays

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
      systems = [ "aarch64-darwin" "x86_64-darwin" ];

      flake = {
        # Top-level flake outputs (darwinConfigurations, etc.)
        darwinConfigurations = {
          Matts-Work-MacBook-Pro = import ./hosts/work { inherit inputs; };
          Matts-Personal-Macbook-Air = import ./hosts/personal { inherit inputs; };
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

### 13. Shared Configuration Library Pattern

Extract common config to `lib/` for DRY host configuration:

```nix
# lib/settings/default.nix - Single source of truth
{
  username = "mattietea";
  email = "mattcthomas@me.com";
  variables = {
    EDITOR = "zed --wait";
    VISUAL = "zed --wait";
  };
}

# lib/modules/default.nix - Function with root parameter for path resolution
{ root }:
let
  app = name: root + "/modules/home-manager/applications/${name}";
  pkg = name: root + "/modules/home-manager/packages/${name}";
in
rec {
  applications = {
    base = [ (app "raycast") (app "zed") (app "spotify") (app "docker") ];
    personal = [ (app "brave") (app "safari") (app "discord") ];
  };
  packages = {
    base = [ (pkg "git") (pkg "fzf") (pkg "claude-code") /* ... */ ];
  };
  allBase = applications.base ++ packages.base;
  allPersonal = allBase ++ applications.personal;
  allWork = allBase;  # Work-specific subset
}

# hosts/*/default.nix - Minimal host config
{ inputs, ... }:
let
  settings = import ../../lib/settings;
  modules = import ../../lib/modules { root = ../..; };
in
inputs.darwin.lib.darwinSystem {
  specialArgs = { inherit inputs settings; };
  modules = [
    {
      users.users.${settings.username} = {
        name = settings.username;
        home = "/Users/${settings.username}";
      };
    }
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager = {
        extraSpecialArgs = { inherit settings inputs; };
        sharedModules = modules.allPersonal;  # or modules.allWork
        users.${settings.username} = {
          home = {
            inherit (settings) username;
            homeDirectory = "/Users/${settings.username}";
            sessionVariables = settings.variables;
          };
        };
      };
    }
    {
      networking.hostName = "Matts-Personal-Macbook-Air";
    }
  ];
}
```

**Pattern**:

- `{ root }` function parameter solves relative path resolution across different importers
- Settings provide user config (username, email, env vars) without duplication
- Module lists enable host-specific subsets (personal vs work)
- Host configs reduced to hostname + module list selection + settings inheritance
- Settings passed via `specialArgs` and `extraSpecialArgs` for system and home-manager access

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: best-practices -->

## Best Practices

### Adding New Tools

1. **Check home-manager first**: Run `nix search nixpkgs <tool>` and check home-manager docs
2. **Create module directory**: `modules/home-manager/packages/<tool>/`
3. **Add default.nix**: Use standard template (see Conventions)
4. **Add to lib/modules/default.nix**: Add `(pkg "tool-name")` to the appropriate list
5. **Test**: Run `devenv shell -- switch`

Note: Adding to `lib/modules/default.nix` automatically enables for all hosts using that module list.

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
