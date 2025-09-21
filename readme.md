# Nix Dotfiles Configuration

Declarative macOS development environment using Nix Flakes, nix-darwin, and home-manager.

## What's Included

**Core Tools:**
- Git ecosystem: git, gh, lazygit, git-absorb, git-machete, graphite
- Shell: zsh with pure prompt, starship, fzf
- Development: node, pnpm, bun, delta, bat, eza, tldr
- Applications: Zed, Raycast, Spotify, Discord

**Architecture:**
- [nix-darwin](https://github.com/LnL7/nix-darwin) - macOS system configuration
- [home-manager](https://github.com/nix-community/home-manager) - User environment management
- Modular configuration with separate work/personal machine profiles

## Setup

1. Clone the repo:
   ```sh
   git clone https://github.com/mattietea/config ~/.config/nix
   ```

2. Update `flake.nix` with your details:
   - username, email
   - hostname (`scutil --get LocalHostName`)

3. Initial build:
   ```sh
   nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake .
   ```

## Daily Commands

```sh
# Apply changes
switch

# Format code
nix fmt -- .

# Update packages
nix flake update

# Clean up old generations
nix-collect-garbage
```

## Structure

- `modules/packages/` - CLI tools and utilities
- `modules/applications/` - GUI applications
- `modules/system/` - System-level configuration
- `flake.nix` - Main configuration with work/personal profiles
