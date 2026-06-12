# Nix Dotfiles Configuration

Declarative macOS development environment using Nix Flakes, nix-darwin, and home-manager.

## Key Features

- **Modular architecture**: 40+ tool configurations, each with its own `default.nix`
- **Multi-host support**: Personal and work hosts share a common app/package baseline (`lib/hosts.nix`) with per-host settings and additions
- **AI-powered development**: Independent configuration for claude-code, codex, and opencode with MCP integration
- **Cross-tool integrations**: fzf + bat/eza, git + delta, and more
- **Reproducible builds**: Everything managed via Nix flakes for complete reproducibility
- **Automated CI/CD**: GitHub Actions evaluate both host configurations on every PR, plus weekly auto-merged dependency updates

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

# Update flake, devenv, and nvfetcher pins
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

# Update packages (flake inputs only — `update` also refreshes devenv + nvfetcher pins)
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

- Defines flake inputs (nixpkgs, nix-darwin, home-manager, agenix, AI tooling)
- Creates host configurations by hostname (`Matts-Personal-Macbook-Air`, `Castula-KQPN`)
- Passes `inputs` directly to host configurations

**Host Configurations (`hosts/personal.nix`, `hosts/work.nix`):**

- Each host defines `settings` inline: username, email, environment variables
- Shared app/package lists and helpers (`commonApps`, `commonPackages`, `app`, `pkg`, `trivialPkg`) live in `lib/hosts.nix`
- Hosts extend the shared baseline with host-specific applications and packages
- Calls `lib/mkHost.nix` builder which handles all darwinSystem boilerplate

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
- Imported via `sharedModules` in host configurations (assembled by `lib/mkHost.nix`)
- To add a new tool: create a new folder with `default.nix` in the appropriate subdirectory (`applications/` or `packages/`) and add it to each host file that should have it
- Folder structure allows for additional files alongside modules (e.g., config files, scripts)

## Structure

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
    ├── ai/                      # AI tooling (harnesses, tools, skills, mcp, plugins, instructions)
    ├── darwin/system/           # macOS system defaults
    │   ├── default.nix          # Importer + meta settings
    │   ├── dock.nix             # Dock, Spaces, Mission Control
    │   ├── finder.nix           # Finder preferences
    │   ├── input.nix            # Keyboard, trackpad, input settings
    │   ├── nix.nix              # Nix settings + binary caches
    │   └── updates.nix          # Software Update settings
    └── home-manager/
        ├── applications/        # GUI apps (brave, zed, discord, etc.)
        │   └── */default.nix
        └── packages/            # CLI tools (git, fzf, zsh, etc.)
            └── */default.nix
```

**Key configuration flow:**

1. `flake.nix` uses `flake-parts.lib.mkFlake` for modular flake structure
2. `flake.nix` imports `hosts/personal.nix` and `hosts/work.nix` directly
3. Each host defines settings inline and extends the shared app/package baseline from `lib/hosts.nix`
4. Hosts call `lib/mkHost.nix` which handles all darwinSystem boilerplate
5. Each module configures a tool using home-manager or `home.packages`
6. AI tools use `enableMcpIntegration` to connect to shared MCP module
7. Cross-tool integrations reference packages via `${pkgs.tool}/bin/tool`
