# GUI Applications Module

Collection of graphical user interface applications.

<!-- AUTO-MANAGED: module-description -->

## Purpose

Houses macOS application configurations for GUI apps installed via home-manager. Each application gets its own subdirectory with a `default.nix` module that uses `home.packages` or app-specific home-manager options.

**Contains applications including**:

- Browser: brave
- Communication: discord, whatsapp (optional)
- Development: zed (editor), docker
- Productivity: raycast, logseq (optional)
- Entertainment: spotify

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: architecture -->

## Module Architecture

```
applications/
├── brave/           # Web browser
├── discord/         # Communication
├── docker/          # Container platform
├── logseq/          # Note-taking (optional)
├── raycast/         # Launcher & productivity
├── spotify/         # Music streaming
├── whatsapp/        # Communication (optional)
└── zed/             # Code editor
    ├── default.nix
    └── utilities.nix
```

**Module Pattern**:

- Each directory has `default.nix`
- Zed has `utilities.nix` for AI config transformation
- Imported by hosts via relative paths in `sharedModules`
- Some modules commented out in host configs (optional installs)

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: conventions -->

## Module-Specific Conventions

### Standard Application Module

Most apps use simple package installation:

```nix
{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.app-name ];
}
```

### Zed Editor Pattern

Zed follows special pattern for AI integration:

```nix
let
  utils = import ./utilities.nix { inherit lib; };
  ai = import ../../ai;
in
{
  programs.zed-editor = {
    enable = true;
    # AI config via utilities transform
    extensions = [ "nix" ];
  };
}
```

### Optional Applications

Some apps are commented out in host configs:

```nix
# hosts/personal/default.nix
sharedModules = [
  # ../../modules/home-manager/applications/logseq   # Commented
  ../../modules/home-manager/applications/brave       # Active
];
```

### macOS App Management

Applications installed via home-manager appear in:

- `~/Applications/Home Manager Apps/`
- Symlinked by `copyApps` activation

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: dependencies -->

## Key Dependencies

**Imports from**:

- `modules/home-manager/ai/` - Shared AI configuration (zed only)

**Imported by**:

- `hosts/personal/default.nix` - Subset of applications
- `hosts/work/default.nix` - Different subset (work-appropriate apps)

**External dependencies**:

- macOS (darwin) - GUI apps only work on macOS
- home-manager `copyApps` - For app directory management

<!-- END AUTO-MANAGED -->

<!-- MANUAL -->

## Custom Notes

Add module-specific notes here.

<!-- END MANUAL -->
