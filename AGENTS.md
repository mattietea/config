# Agent Commands

This is a Nix dotfiles configuration project using home-manager, nix-darwin, and nixpkgs.

**When asked about packages or libraries, always use context7 to search for documentation.**

## Run within devenv

Before running any commands, ensure you're in the devenv shell:

```sh
devenv shell
```

**Or run a single command without entering the shell:**

```sh
devenv shell -- command
```

Examples:

```sh
devenv shell -- format
devenv shell -- "format && lint"
```

## Available Commands

- `switch` - Apply changes to nix-darwin
- `format` - Format all files (uses treefmt with nixfmt, prettier, yamlfmt)
- `lint` - Lint Nix files (uses statix)
- `update` - Update flake inputs
- `clean` - Clean up old Nix generations

Run these commands from within the devenv shell.
