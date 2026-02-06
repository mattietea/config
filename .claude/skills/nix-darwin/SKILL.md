---
name: nix-darwin
description: "nix-darwin system configuration and flake management. Use when modifying macOS system defaults, flake inputs, host files, or the mkHost builder in this dotfiles repo."
---

# nix-darwin System Configuration

## Flake Inputs

1. In nixpkgs already? Just use `pkgs.tool`
2. Depends on nixpkgs? Add `inputs.nixpkgs.follows = "nixpkgs"`
3. Not a flake (just source)? Use `flake = false`

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

## Gotchas

- `git add` new files before `nix flake check` — untracked files are invisible to flakes
- `system.stateVersion` — do not change without reading `darwin-rebuild changelog`
- `CustomUserPreferences` for per-user domains (trackpad gestures, symbolic hotkeys)
