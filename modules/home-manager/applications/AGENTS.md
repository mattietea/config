# GUI Applications Module

Collection of graphical user interface applications.

<!-- AUTO-MANAGED: module-description -->

## Purpose

Houses macOS application configurations for GUI apps installed via home-manager. Each application gets its own subdirectory with a `default.nix` module.

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

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: conventions -->

## Module-Specific Conventions

See root `AGENTS.md` for standard module template. Most apps use simple `home.packages = [ pkgs.app-name ];`.

### Zed Editor Pattern

Zed uses home-manager's `programs.zed-editor` with extensions and userSettings. See `zed/default.nix`.

### macOS App Management

- Apps installed via home-manager appear in `~/Applications/Home Manager Apps/`
- App Store apps use `mas` CLI with `home.activation` scripts (see `safari/default.nix` for example)
- Find App Store IDs: `mas search <name>` or from App Store URLs

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: dependencies -->

## Key Dependencies

**Imported by**: `hosts/personal.nix` and `hosts/work.nix` as `sharedModules` paths

**External dependencies**:

- macOS (darwin) - GUI apps only work on macOS
- home-manager `copyApps` - For app directory management

<!-- END AUTO-MANAGED -->

<!-- MANUAL -->

## Custom Notes

Add module-specific notes here.

<!-- END MANUAL -->
