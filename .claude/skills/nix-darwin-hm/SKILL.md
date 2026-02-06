---
name: nix-darwin-hm
description: "Nix patterns for nix-darwin + home-manager macOS dotfiles. Use when writing or modifying Nix modules, flake inputs, host configs, or cross-tool integrations in this repository."
---

# Nix Darwin + Home Manager Patterns

## This Repository's Module Pattern

Modules here are **simple config-only** — no custom options, no `mkIf`/`mkEnableOption`. Each tool gets a `default.nix` that directly sets `programs.*` or `home.packages`.

### With home-manager support (preferred)

```nix
{
  pkgs,
  ...
}:
{
  programs.tool = {
    enable = true;
    enableZshIntegration = true;
  };
}
```

### Without home-manager support

```nix
{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.tool ];
}
```

### With settings or inputs

```nix
{
  pkgs,
  settings,
  inputs,
  ...
}:
{
  programs.tool = {
    enable = true;
    package = inputs.tool-flake.packages.${pkgs.system}.default;
    config = settings.variables.EDITOR;
  };
}
```

## Writing Nix

### Never use `with`

Breaks static analysis, LSP, and readability.

```nix
# BAD
meta = with lib; { license = licenses.mit; };

# GOOD
meta = { license = lib.licenses.mit; };
```

### Never use `rec`

Causes infinite recursion risk. Use `let-in` instead.

```nix
# BAD
rec { version = "1.0"; name = "pkg-${version}"; }

# GOOD
let version = "1.0";
in { inherit version; name = "pkg-${version}"; }
```

### Library access

| Situation         | Pattern                                     |
| ----------------- | ------------------------------------------- |
| 1-2 lib functions | Inline `lib.mkIf`, `lib.mkDefault`          |
| 3+ lib functions  | `inherit (lib) mkIf mkOption types;` in let |
| Module-level      | NEVER `with lib;`                           |

### Destructure arguments

```nix
# BAD
args: { name = args.pname; }

# GOOD
{ pkgs, settings, ... }: { }
```

## Flake Inputs

### Adding dependencies

1. In nixpkgs already? Just use `pkgs.tool`
2. Depends on nixpkgs? Add `inputs.nixpkgs.follows = "nixpkgs"`
3. Not a flake (just source)? Use `flake = false`

```nix
# Flake input with follows
tool-flake.url = "github:owner/tool";
tool-flake.inputs.nixpkgs.follows = "nixpkgs";

# Non-flake source
tool-src = {
  url = "github:owner/tool";
  flake = false;
};
```

### Update inputs

```bash
nix flake update tool-flake   # Single input
nix flake update              # All inputs
```

## Cross-Tool References

Always use full package path — never hardcode binary locations.

```nix
# Reference another tool's binary
fileWidgetOptions = [
  "--preview '${pkgs.bat}/bin/bat --color=always {}'"
];

# Shell aliases
shellAliases = {
  cat = "${pkgs.bat}/bin/bat";
};
```

## Conditional Patterns

For the rare cases where conditions are needed:

| Need                     | Use                  |
| ------------------------ | -------------------- |
| Conditional config block | `lib.mkIf`           |
| Conditional list items   | `lib.optionals`      |
| Conditional string       | `lib.optionalString` |
| Combine conditionals     | `lib.mkMerge`        |
| Simple value selection   | `if x then a else b` |

```nix
home.packages = [
  pkgs.coreutils
] ++ lib.optionals pkgs.stdenv.isDarwin [
  pkgs.darwin-tool
];
```

## Naming Conventions

| Element     | Style         | Example                        |
| ----------- | ------------- | ------------------------------ |
| Variables   | camelCase     | `userName`, `enableFeature`    |
| Files/dirs  | kebab-case    | `git-absorb/`, `rename-utils/` |
| Module file | `default.nix` | Always                         |
| Constants   | UPPER_CASE    | `MAX_RETRIES`                  |

## Formatting & Validation

- `nixfmt` via treefmt for formatting
- `statix` for anti-pattern detection
- `shellcheck` for shell scripts in Nix
- `nix flake check --no-build` for structure validation

## Common Gotchas

- **`git add` before `nix flake check`**: Untracked files are invisible to flakes
- **Single `programs` block per module**: Statix errors on repeated attribute keys
- **`enableZshIntegration`**: Provides aliases and completions — usually want `true`
- **`home.activation`**: For imperative actions (mas installs), use `lib.hm.dag.entryAfter [ "writeBoundary" ]`
