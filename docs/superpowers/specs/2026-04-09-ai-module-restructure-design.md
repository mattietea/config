# AI Module Restructure Design

## Problem

AI tool configuration (claude-code, opencode, skills, MCPs) is scattered across 10+ directories inside `modules/home-manager/packages/`, mixed in with non-AI tools like git and fzf. There's no global instruction file shared across AI harnesses (Claude Code, Codex, OpenCode). Host files must import ~10 AI modules individually.

## Solution

Consolidate all AI configuration into a dedicated `modules/ai/` directory with clear taxonomy, aggregator files for simple host imports, and a new instructions module that deploys a single source-of-truth markdown file to all three AI harnesses.

## Folder Structure

```
modules/ai/
  default.nix                          # aggregator: imports harnesses, skills, mcp, instructions (base)
  work.nix                             # aggregator: imports */work.nix variants
  personal.nix                         # aggregator: imports */personal.nix variants
  harnesses/
    claude-code/
      default.nix                      # from packages/claude-code/default.nix
    opencode/
      default.nix                      # from packages/opencode/default.nix
      oh-my-opencode-base.nix          # from packages/opencode/oh-my-opencode-base.nix
      work.nix                         # from packages/opencode-work/default.nix
      personal.nix                     # from packages/opencode-personal/default.nix
  skills/
    default.nix                        # from packages/skills/default.nix
    work.nix                           # from packages/skills-work/default.nix
    personal.nix                       # from packages/skills-personal/default.nix
  mcp/
    default.nix                        # from packages/mcp/default.nix
    work.nix                           # from packages/mcp-work/default.nix
    personal.nix                       # from packages/mcp-personal/default.nix
  instructions/
    default.nix                        # home.file symlinks for 3 targets
    INSTRUCTIONS.md                    # single source-of-truth instruction file
```

## File Moves

| Current                                     | New                                             |
| ------------------------------------------- | ----------------------------------------------- |
| `packages/claude-code/default.nix`          | `ai/harnesses/claude-code/default.nix`          |
| `packages/opencode/default.nix`             | `ai/harnesses/opencode/default.nix`             |
| `packages/opencode/oh-my-opencode-base.nix` | `ai/harnesses/opencode/oh-my-opencode-base.nix` |
| `packages/opencode-work/default.nix`        | `ai/harnesses/opencode/work.nix`                |
| `packages/opencode-personal/default.nix`    | `ai/harnesses/opencode/personal.nix`            |
| `packages/skills/default.nix`               | `ai/skills/default.nix`                         |
| `packages/skills-work/default.nix`          | `ai/skills/work.nix`                            |
| `packages/skills-personal/default.nix`      | `ai/skills/personal.nix`                        |
| `packages/mcp/default.nix`                  | `ai/mcp/default.nix`                            |
| `packages/mcp-work/default.nix`             | `ai/mcp/work.nix`                               |
| `packages/mcp-personal/default.nix`         | `ai/mcp/personal.nix`                           |

## Aggregator Files

### `ai/default.nix`

Imports all base AI modules:

```nix
{
  imports = [
    ./harnesses/claude-code
    ./harnesses/opencode
    ./skills
    ./mcp
    ./instructions
  ];
}
```

### `ai/work.nix`

Imports work-specific overrides:

```nix
{
  imports = [
    ./harnesses/opencode/work.nix
    ./skills/work.nix
    ./mcp/work.nix
  ];
}
```

### `ai/personal.nix`

Imports personal-specific overrides:

```nix
{
  imports = [
    ./harnesses/opencode/personal.nix
    ./skills/personal.nix
    ./mcp/personal.nix
  ];
}
```

## Instructions Module

### `ai/instructions/default.nix`

Deploys the instruction file to all three harness global paths:

```nix
{ ... }:
{
  home.file = {
    ".claude/CLAUDE.md".source = ./INSTRUCTIONS.md;
    ".codex/AGENTS.md".source = ./INSTRUCTIONS.md;
    ".config/opencode/AGENTS.md".source = ./INSTRUCTIONS.md;
  };
}
```

### `ai/instructions/INSTRUCTIONS.md`

Single source-of-truth containing universal preferences (coding style, response format, tool behavior). Content to be filled in by user.

### Harness Compatibility

| Tool        | Global Path                    | Auto-loaded? |
| ----------- | ------------------------------ | ------------ |
| Claude Code | `~/.claude/CLAUDE.md`          | Yes          |
| Codex       | `~/.codex/AGENTS.md`           | Yes          |
| OpenCode    | `~/.config/opencode/AGENTS.md` | Yes          |

## Host File Changes

### `lib/mkHost.nix`

Add `ai ? [ ]` parameter and include in `sharedModules`:

```nix
{
  inputs,
  settings,
  hostname,
  system ? "aarch64-darwin",
  applications ? [ ],
  packages ? [ ],
  ai ? [ ],
}:
# ...
sharedModules = applications ++ packages ++ ai;
```

### `hosts/work.nix`

```nix
mkHost {
  inherit inputs settings;
  hostname = "Castula-KQPN";
  applications = [ (app "brave") (app "zed") ... ];
  packages = [ (pkg "git") (pkg "fzf") ... ];
  ai = [
    ../modules/ai
    ../modules/ai/work.nix
  ];
}
```

### `hosts/personal.nix`

```nix
mkHost {
  inherit inputs settings;
  hostname = "Matts-Personal-Macbook-Air";
  applications = [ (app "brave") (app "zed") ... ];
  packages = [ (pkg "git") (pkg "fzf") ... ];
  ai = [
    ../modules/ai
    ../modules/ai/personal.nix
  ];
}
```

## Relative Import Path Updates

Variant files currently import their base module explicitly. After the move, these imports are **removed** since the aggregator `ai/default.nix` already imports all base modules. This avoids double-imports and simplifies the dependency graph.

**Constraint**: `ai/work.nix` and `ai/personal.nix` must always be imported alongside `ai/default.nix`. Host files enforce this by always listing both.

| File (new path)                      | Remove                                                                            | Reason                    |
| ------------------------------------ | --------------------------------------------------------------------------------- | ------------------------- |
| `ai/harnesses/opencode/work.nix`     | `imports = [ ../opencode ];`                                                      | Base loaded by aggregator |
| `ai/harnesses/opencode/work.nix`     | `import ../opencode/oh-my-opencode-base.nix` → `import ./oh-my-opencode-base.nix` | Same directory after move |
| `ai/harnesses/opencode/personal.nix` | `imports = [ ../opencode ];`                                                      | Base loaded by aggregator |
| `ai/harnesses/opencode/personal.nix` | `import ../opencode/oh-my-opencode-base.nix` → `import ./oh-my-opencode-base.nix` | Same directory after move |
| `ai/mcp/work.nix`                    | `imports = [ ../mcp ];`                                                           | Base loaded by aggregator |
| `ai/mcp/personal.nix`                | `imports = [ ../mcp ];`                                                           | Base loaded by aggregator |

## Documentation Updates

After the move, update these files to reflect new AI module paths:

- `CLAUDE.md` — update all references to `modules/home-manager/packages/mcp/`, `modules/home-manager/packages/claude-code/`, and other moved AI modules to `modules/ai/` paths
- `modules/home-manager/packages/AGENTS.md` — remove AI tool entries from architecture diagram and cross-package dependencies

## Directories Removed

After the move, these 10 directories are deleted from `modules/home-manager/packages/`:

- `claude-code/`
- `opencode/`
- `opencode-work/`
- `opencode-personal/`
- `skills/`
- `skills-work/`
- `skills-personal/`
- `mcp/`
- `mcp-work/`
- `mcp-personal/`

## What Doesn't Change

- Zed stays in `applications/` — consumes MCP via `enableMcpIntegration`
- All non-AI packages stay in `packages/`
- `flake.nix` inputs unchanged
- Internal module logic unchanged — only file locations, import paths, and redundant base imports change
- `enableMcpIntegration` pattern unchanged

## Validation

- `devenv shell -- switch` must succeed on both hosts
- All AI tools must retain their current configuration
- Global instruction file must appear at all three target paths
- `format` and `lint` must pass
