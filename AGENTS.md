# Nix Dotfiles Configuration

Personal nix dotfiles using home-manager, nix-darwin, and nixpkgs.

## Project Structure

- **Modular design**: Each tool gets its own `default.nix`
- **Two hosts**: `personal` and `work` (shared modules, different apps)
- **Tools integrate**: Shell, git, editor integrations work together

```
modules/
├── darwin/system/          # macOS system defaults
└── home-manager/
    ├── applications/       # GUI apps (brave, zed, discord, etc.)
    └── packages/           # CLI tools (git, fzf, zsh, etc.)
```

## Documentation

**Always use context7 to search for nix/home-manager documentation.**

## Adding New Tools

1. **Always try home-manager first** - Check if `programs.<tool>.enable` exists
2. **If no home-manager support** - Use `home.packages = [ pkgs.<tool> ]`
3. **Look at existing integrations** - Check how similar tools are configured
4. **Consider cross-tool integration** - Shell integration, editor integration, etc.

### Directory Structure

- CLI tools: `modules/home-manager/packages/<tool>/default.nix`
- GUI apps: `modules/home-manager/applications/<tool>/default.nix`

### Configuration Patterns

**Simple package** (no home-manager support):

```nix
{ pkgs, ... }:
{
  home.packages = [ pkgs.tool ];
}
```

**Program with home-manager support**:

```nix
{ pkgs, ... }:
{
  programs.tool = {
    enable = true;
    enableZshIntegration = true;  # if available
  };
}
```

**With cross-tool integration** (reference other packages):

```nix
{ pkgs, ... }:
{
  programs.fzf = {
    enable = true;
    fileWidgetOptions = [
      "--preview '${pkgs.bat}/bin/bat --color=always {}'"
    ];
  };
}
```

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
