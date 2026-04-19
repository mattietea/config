---
name: nix-darwin
description: "nix-darwin system configuration and flake management. Use when modifying macOS system defaults, flake inputs, host files, or the mkHost builder in this dotfiles repo."
---

# nix-darwin System Configuration

## Flake Inputs

1. In nixpkgs already? Just use `pkgs.tool`
2. Depends on nixpkgs? Add `inputs.nixpkgs.follows = "nixpkgs"`
3. Not a flake (just source)? Use `flake = false`
4. **Check for a binary cache** — see [Binary Caches](#binary-caches) below

```nix
tool-flake.url = "github:owner/tool";
tool-flake.inputs.nixpkgs.follows = "nixpkgs";

tool-src = { url = "github:owner/tool"; flake = false; };
```

## Host Files

Each host is self-contained at `hosts/<name>.nix`. To add a tool, add `(pkg "tool")` to both files.

## macOS System Defaults

Configured in `modules/darwin/system/default.nix`. Use the NixOS MCP to look up options:

```
mcp__nixos__nix(action="search", source="darwin", type="options", query="system.defaults.<area>")
```

Key areas: `system.defaults.dock`, `system.defaults.finder`, `system.defaults.NSGlobalDomain`, `system.defaults.trackpad`, `system.keyboard`.

## Binary Caches

Configured in `modules/darwin/system/nix.nix` via `extra-substituters` and `extra-trusted-public-keys`.

### When adding a flake input that builds from source

**Always check for a cachix cache.** Without one, Rust/Tauri/Go packages can add 100+ source builds.

```bash
# Check if a cachix cache exists (name = repo name, owner, or project)
curl -s https://app.cachix.org/api/v1/cache/<name>
# Success → returns JSON with uri + publicSigningKeys
# Failure → "doesn't exist" message
```

If found, add to `modules/darwin/system/nix.nix`:

```nix
extra-substituters = ... https://<name>.cachix.org
extra-trusted-public-keys = ... <name>.cachix.org-1:<key>=
```

### `nixpkgs.follows` and binary caches

Adding `inputs.nixpkgs.follows = "nixpkgs"` pins the input to YOUR nixpkgs. This means:

- ✅ One nixpkgs evaluation, smaller closure
- ❌ Derivation hashes change → upstream binary cache misses → full source rebuild

**Rule of thumb:** If the input has a binary cache and builds heavy native code (Rust, Go, C++), do NOT add `follows` — let it use its own nixpkgs pin. See the `opencode` input in `flake.nix` for an example.

### Current caches

| Cache                        | Covers                                       |
| ---------------------------- | -------------------------------------------- |
| `cache.nixos.org`            | nixpkgs (default)                            |
| `devenv.cachix.org`          | devenv                                       |
| `nix-community.cachix.org`   | home-manager, nix-darwin, community packages |
| `opencode.cachix.org`        | opencode + opencode-desktop (Tauri/Rust)     |
| `claude-code-nix.cachix.org` | claude-code                                  |

## Gotchas

- `git add` new files before `nix flake check` — untracked files are invisible to flakes
- `system.stateVersion` — do not change without reading `darwin-rebuild changelog`
- `CustomUserPreferences` for per-user domains (trackpad gestures, symbolic hotkeys)
- Missing binary cache = hundreds of source builds — always check when adding flake inputs
