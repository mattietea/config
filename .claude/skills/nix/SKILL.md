---
name: nix
description: "Idiomatic Nix language patterns and anti-patterns. Use when writing or reviewing any Nix code: avoiding `with` and `rec`, proper lib access, conditionals, naming conventions, and formatting."
---

# Writing Nix

## Anti-Patterns

### Never use `with`

Breaks static analysis, LSP, and readability.

```nix
# BAD
meta = with lib; { license = licenses.mit; };

# GOOD
meta = { license = lib.licenses.mit; };
```

### Never use `rec`

Use `let-in` instead — `rec` risks infinite recursion.

```nix
# BAD
rec { version = "1.0"; name = "pkg-${version}"; }

# GOOD
let version = "1.0";
in { inherit version; name = "pkg-${version}"; }
```

## Library Access

| Situation         | Pattern                                     |
| ----------------- | ------------------------------------------- |
| 1-2 lib functions | Inline `lib.mkIf`, `lib.mkDefault`          |
| 3+ lib functions  | `inherit (lib) mkIf mkOption types;` in let |
| Module-level      | NEVER `with lib;`                           |

## Destructure Arguments

```nix
# BAD
args: { name = args.pname; }

# GOOD
{ pkgs, settings, ... }: { }
```

## Conditionals

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

## Naming

| Element    | Style         | Example                        |
| ---------- | ------------- | ------------------------------ |
| Variables  | camelCase     | `userName`, `enableFeature`    |
| Files/dirs | kebab-case    | `git-absorb/`, `rename-utils/` |
| Module     | `default.nix` | Always                         |

## Validation

- `nixfmt` via treefmt for formatting
- `statix` for anti-pattern detection
- `shellcheck` for embedded shell scripts
- `nix flake check --no-build` for structure
