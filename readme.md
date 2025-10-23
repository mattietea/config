# Nix Dotfiles Configuration

Declarative macOS development environment using Nix Flakes, nix-darwin, and home-manager.

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

```sh
# Apply changes
switch

# Format code
nix fmt

# Update packages
nix flake update

# Clean up old generations
nix-collect-garbage
```

## How It Works

The configuration uses a modular architecture that automatically loads all modules:

**Entry Point (`flake.nix`):**
- Defines flake inputs (nixpkgs, nix-darwin, home-manager)
- Creates host configurations by hostname (e.g., `Matts-Work-MacBook-Pro`)
- Imports the `mkDarwinHost` helper from `utilities/`

**Host Configurations (`hosts/work/`, `hosts/personal/`):**
- Each host defines:
  - `settings`: username, email, environment variables
  - `apps`: GUI applications to enable
  - `packages`: CLI tools to enable

**System Configuration (`system/darwin.nix`):**
- macOS system preferences (Dock, Finder, trackpad, keyboard)
- Applied globally to all hosts

**Module Files (`modules/applications/`, `modules/packages/`):**
- Each `.nix` file defines a single application or package
- Uses NixOS module system with `enable` options
- Automatically discovered and loaded via `builtins.readDir`
- To add a new tool: just create a new `.nix` file in the appropriate directory

## Structure

```
├── flake.nix                    # Flake inputs and host configurations
├── hosts/
│   ├── work/default.nix         # Work machine configuration
│   └── personal/default.nix     # Personal machine configuration
├── utilities/default.nix        # mkDarwinHost helper function
├── system/darwin.nix            # macOS system preferences
├── modules/
│   ├── applications/            # GUI apps (auto-imported)
│   │   ├── discord.nix
│   │   ├── raycast.nix
│   │   ├── spotify.nix
│   │   └── zed.nix
│   └── packages/                # CLI tools (auto-imported)
│       ├── git.nix
│       ├── zsh.nix
│       ├── fzf.nix
│       └── ...
```
