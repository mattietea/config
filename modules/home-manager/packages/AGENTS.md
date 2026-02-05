# CLI Tools & Packages Module

Collection of command-line tools and development utilities.

<!-- AUTO-MANAGED: module-description -->

## Purpose

Houses individual tool configurations for CLI utilities, development tools, and command-line applications. Each tool gets its own subdirectory with a `default.nix` module that configures it using home-manager when available, or falls back to `home.packages`.

**Contains 25+ tools including**:

- Version control: git, gh, lazygit, git-absorb
- Shell & navigation: zsh, fzf, zoxide, eza
- Development: devenv, mise, node, bun
- Editor integration: bat, delta
- AI tools: claude-code, opencode

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: architecture -->

## Module Architecture

```
packages/
├── aerospace/       # Window manager
├── bat/             # Cat replacement with syntax highlighting
├── claude-code/     # AI coding assistant
├── devenv/          # Development environments
├── fzf/             # Fuzzy finder
├── git/             # Git configuration
├── mcp/             # MCP server configuration
├── zsh/             # Shell configuration
└── ... (25+ more)
```

**Module Pattern**:

- Each directory has `default.nix`
- Imported by hosts via relative paths in `sharedModules`

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: conventions -->

## Module-Specific Conventions

### Standard Module Structure

**With home-manager support** (preferred):

```nix
{
  pkgs,
  ...
}:
{
  programs.tool = {
    enable = true;
    enableZshIntegration = true;  # if available
    # tool-specific config
  };
}
```

**Without home-manager support**:

```nix
{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.tool ];
}
```

### Cross-Package References

Reference other packages via `${pkgs.tool}/bin/tool`:

```nix
# fzf/default.nix references bat and eza
fileWidgetOptions = [
  "--preview '${pkgs.bat}/bin/bat --color=always {}'"
];
changeDirWidgetOptions = [
  "--preview '${pkgs.eza}/bin/eza --tree {}'"
];
```

### AI Tool Pattern

AI tools (claude-code, opencode) configure independently:

```nix
{
  home.packages = [ /* dependencies */ ];
  programs.tool = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      model = "opus";  # Shorthand: opus, sonnet, or haiku
      # ... other tool-specific settings
    };
  };
}
```

**Model configuration**: claude-code uses top-level `settings.model` with shorthand names (`"opus"`, `"sonnet"`, `"haiku"`), while opencode configures per-agent models in `oh-my-opencode.json`.

**MCP Integration**: Set `enableMcpIntegration = true` to use servers from `packages/mcp/default.nix`.

### Settings Parameter

Tools needing user info receive `settings` parameter:

```nix
{
  pkgs,
  settings,  # Passed via specialArgs
  ...
}:
{
  programs.tool = {
    enable = true;
    config = settings.variables.EDITOR;
  };
}
```

### External Package Pattern (Non-Nixpkgs)

For tools not in nixpkgs, use flake inputs with custom derivation:

```nix
{
  inputs,  # Access flake inputs
  pkgs,
  lib,
  ...
}:
let
  version = inputs.tool-src.shortRev or "latest";

  tool = pkgs.stdenv.mkDerivation {
    pname = "tool";
    inherit version;
    src = inputs.tool-src;
    # ... build logic
  };
in
{
  home.packages = [ tool ];
}
```

### Hybrid Bash + Go Build Pattern

For packages with bash scripts + Go binaries:

```nix
let
  # Build Go binaries separately
  go-helpers = pkgs.buildGoModule {
    pname = "tool-go-helpers";
    src = inputs.tool-src;
    proxyVendor = true;  # Bypass out-of-sync vendor
    overrideModAttrs = _: {
      modPostBuild = "go mod tidy";
    };
    vendorHash = "sha256-...";
    subPackages = [ "cmd/helper1" "cmd/helper2" ];
  };

  # Assemble final package
  tool = pkgs.stdenv.mkDerivation {
    src = inputs.tool-src;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/libexec $out/bin
      cp -r bin lib $out/libexec/
      cp ${go-helpers}/bin/* $out/libexec/bin/
      substitute main $out/bin/tool \
        --replace 'SCRIPT_DIR="..."' "SCRIPT_DIR='$out/libexec'"
    '';
  };
in
```

**buildGoModule tips**:

- `proxyVendor = true` - When upstream vendor/ is out of sync
- `overrideModAttrs` with `modPostBuild = "go mod tidy"` - Fix dependency mismatches
- `subPackages` - List specific Go packages to build
- After `update`, if vendorHash fails: use fake hash `"sha256-AAAA..."`, get real hash from error

<!-- END AUTO-MANAGED -->

<!-- AUTO-MANAGED: dependencies -->

## Key Dependencies

**Imports from**:

- Host `settings` via `specialArgs` - User info, environment variables

**Imported by**:

- `hosts/personal/default.nix` - As `sharedModules` paths
- `hosts/work/default.nix` - As `sharedModules` paths

**Cross-package dependencies**:

- fzf → bat, eza (preview integration)
- git → delta (diff viewer)
- zsh → multiple tools (shell integration)
- claude-code → terminal-notifier (plugin dependencies)
- AI tools → mcp (MCP server configuration via enableMcpIntegration)

<!-- END AUTO-MANAGED -->

<!-- MANUAL -->

## Custom Notes

Add module-specific notes here.

<!-- END MANUAL -->
