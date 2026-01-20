# Shared Library

Common configuration shared across all hosts.

## Structure

```
lib/
├── AGENTS.md
├── CLAUDE.md -> AGENTS.md
├── settings/default.nix    # User settings (username, email, env vars)
└── modules/default.nix     # Shared module lists with path resolution
```

## Usage

```nix
let
  settings = import ../../lib/settings;
  modules = import ../../lib/modules { root = ../..; };
in
{
  users.users.${settings.username} = { ... };
  home-manager.sharedModules = modules.allPersonal;  # or modules.allWork
}
```

## Module Lists

| Name          | Contents                                                 |
| ------------- | -------------------------------------------------------- |
| `allBase`     | Core apps (raycast, zed, spotify, docker) + all packages |
| `allPersonal` | allBase + personal apps (brave, safari, discord)         |
| `allWork`     | allBase only                                             |

## Path Resolution

`modules/default.nix` uses a function pattern for Nix path resolution:

```nix
{ root }:
let
  app = name: root + "/modules/home-manager/applications/${name}";
  pkg = name: root + "/modules/home-manager/packages/${name}";
in
rec { ... }
```

This ensures paths resolve correctly regardless of which file imports the module.
