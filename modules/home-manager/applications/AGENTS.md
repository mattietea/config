# GUI Applications Module

Collection of graphical user interface applications.

<!-- AUTO-MANAGED: module-description -->

## Purpose

Houses macOS application configurations for GUI apps installed via home-manager. Each application gets its own subdirectory with a `default.nix` module that uses `home.packages` or app-specific home-manager options.

**Contains applications including**:

- Browser: brave, google-chrome, safari (extensions via mas)
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
├── google-chrome/   # Web browser
├── logseq/          # Note-taking (optional)
├── raycast/         # Launcher & productivity
├── safari/          # Safari extensions (via mas)
├── spotify/         # Music streaming
├── whatsapp/        # Communication (optional)
└── zed/             # Code editor
```

**Module Pattern**:

- Each directory has `default.nix`
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

Zed uses standard home-manager configuration:

```nix
{
  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" "opencode" ];
    userSettings = {
      # ... editor settings
    };
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

### Mac App Store Apps (mas pattern)

For Safari extensions and App Store-only apps, use `mas` CLI with activation scripts:

```nix
{
  pkgs,
  lib,
  ...
}:
let
  masApps = {
    "App Name" = 1234567890;  # App Store ID
  };
in
{
  home.packages = [ pkgs.mas ];

  home.activation.installMasApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: id: ''
        if ! ${pkgs.mas}/bin/mas list | grep -q "^${toString id} "; then
          echo "Installing ${name}..."
          ${pkgs.mas}/bin/mas install ${toString id}
        fi
      '') masApps
    )}
  '';
}
```

**Key points**:

- Find App Store IDs: `mas search <name>` or from App Store URLs
- Idempotent: checks before installing
- `lib.hm.dag.entryAfter [ "writeBoundary" ]` ensures proper activation ordering
- Used by: `safari/` module for extensions (1Blocker, SponsorBlock)

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: dependencies -->

## Key Dependencies

**Imports from**:

- None (applications use home-manager options directly)

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
