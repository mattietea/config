# Nix Dotfiles Configuration

Declarative macOS development environment using Nix Flakes, nix-darwin, and home-manager.

## Key Features

- **Modular architecture**: 45+ tool configurations, each with its own `default.nix`
- **Multi-host support**: Separate personal and work configurations sharing common modules
- **AI-powered development**: Unified configuration for claude-code, opencode, and zed with Sisyphus multi-agent orchestration
- **Cross-tool integrations**: fzf + bat/eza, git + delta, and more
- **Reproducible builds**: Everything managed via Nix flakes for complete reproducibility

## Setup

1. Install [Determinate Nix](https://docs.determinate.systems)

2. Clone the repo:

   ```sh
   git clone https://github.com/mattietea/config ~/.config/nix
   ```

3. Initial build:
   ```sh
   sudo -i nix run nix-darwin -- switch --flake ~/.config/nix
   ```

## Daily Commands

### Using devenv (Recommended)

This project uses [devenv](https://devenv.sh/) for development environment management. Enter the devenv shell to access all tools:

```sh
devenv shell
```

Available scripts (run from within devenv shell or via `devenv shell -- <script>`):

```sh
# Apply changes to nix-darwin
switch

# Format all files (uses treefmt with nixfmt, prettier, yamlfmt)
format

# Lint Nix files (uses statix)
lint

# Update flake inputs
update

# Clean up old Nix generations
clean
```

### Direct Nix Commands

```sh
# Apply changes
sudo darwin-rebuild switch --flake .

# Format code
nix fmt

# Update packages
nix flake update

# Clean up old generations
nix-collect-garbage
```

### Updating Nix

```sh
sudo determinate-nixd upgrade
```

## Development Environment

This project uses [devenv](https://devenv.sh/) to manage the development environment. The `devenv.nix` file configures:

- **Language Server**: nixd for Nix language support
- **Formatting**: treefmt with nixfmt (RFC 0076), prettier, and yamlfmt
- **Linting**: statix for Nix files, shellcheck for shell scripts
- **Git Hooks**: Automatic formatting and linting on commit

### Formatting

All formatting uses RFC 0076 style via `nixfmt`:

- VS Code format-on-save uses nixfmt
- `treefmt` command uses nixfmt for Nix files
- Git hooks use treefmt (which uses nixfmt)

### VS Code Integration

VS Code is configured to use tools from the devenv environment:

- nix-ide extension uses nixd from devenv
- Formatting uses nixfmt from devenv
- All tools are automatically available when working in this project

## How It Works

The configuration uses a modular architecture following standard nix-darwin and home-manager patterns:

**Entry Point (`flake.nix`):**

- Defines flake inputs (nixpkgs, nix-darwin, home-manager)
- Creates host configurations by hostname (e.g., `Matts-Work-MacBook-Pro`)
- Passes `inputs` directly to host configurations

**Host Configurations (`hosts/work/`, `hosts/personal/`):**

- Each host directly calls `darwin.lib.darwinSystem` (standard pattern)
- Defines `settings`: username, email, environment variables
- Imports darwin modules (system-level configuration)
- Lists all home-manager modules in `sharedModules` (user-level configuration)
- Configures home-manager integration

**Darwin Modules (`modules/darwin/`):**

- System-level macOS configuration
- macOS system preferences (Dock, Finder, trackpad, keyboard)
- Applied globally to all hosts via module import
- Each module is a folder with a `default.nix` file
- Example: `modules/darwin/system/default.nix`

**Home Manager Modules (`modules/home-manager/`):**

- User-level configuration (dotfiles, user packages, programs)
- Organized into `applications/` (GUI apps) and `packages/` (CLI tools)
- Each module is a folder with a `default.nix` file
- Uses home-manager module system
- Imported via `sharedModules` in host configurations
- To add a new tool: create a new folder with `default.nix` in the appropriate subdirectory (`applications/` or `packages/`) and add it to the `sharedModules` list in the appropriate host file
- Folder structure allows for additional files alongside modules (e.g., config files, scripts)

## Structure

```
.
├── flake.nix                    # Flake inputs and outputs
├── devenv.nix                   # Development environment & scripts
├── .claude/auto-memory/         # Auto-memory plugin cache (gitignored)
├── .vscode/                     # VS Code workspace settings
│   ├── settings.json            # Editor configuration (formatting, linting)
│   └── extensions.json          # Recommended extensions
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

**Key configuration flow:**

1. `hosts/{personal,work}/default.nix` imports modules via `sharedModules`
2. Each module configures a tool using home-manager or `home.packages`
3. AI tools (claude-code, opencode, zed) share config from `modules/home-manager/ai/`
4. Cross-tool integrations reference packages via `${pkgs.tool}/bin/tool`
