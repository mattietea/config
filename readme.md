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
├── flake.nix                    # Flake inputs and host configurations
├── hosts/
│   ├── work/default.nix         # Work machine configuration
│   └── personal/default.nix     # Personal machine configuration
├── modules/
│   ├── darwin/                  # System-level configuration (nix-darwin)
│   │   └── system/
│   │       └── default.nix      # macOS system preferences
│   └── home-manager/            # User-level configuration (home-manager)
│       ├── applications/        # GUI applications
│       │   ├── discord/
│       │   │   └── default.nix
│       │   ├── raycast/
│       │   │   └── default.nix
│       │   ├── spotify/
│       │   │   └── default.nix
│       │   ├── whatsapp/
│       │   │   └── default.nix
│       │   └── zed/
│       │       └── default.nix
│       └── packages/            # CLI tools and packages
│           ├── git/
│           │   └── default.nix
│           ├── zsh/
│           │   └── default.nix
│           └── ...
```
