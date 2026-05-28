# Replace Slack MCP with stablyai/agent-slack (CLI + Skill)

## TL;DR

> **Quick Summary**: Replace the work-host's remote Slack MCP server with stablyai/agent-slack — a CLI binary + agent skill. Add `agent-slack` as a Nix flake input, install the CLI on the work host via a dedicated package module, wire the shipped skill into `programs.agent-skills` (work scope), and remove the old MCP entry.
>
> **Deliverables**:
>
> - New flake input `agent-slack` in `flake.nix`
> - New package module `modules/home-manager/packages/agent-slack/default.nix`
> - `(pkg "agent-slack")` added to `hosts/work.nix`
> - `agent-slack` skill source + `skills.enable` entry in `modules/ai/skills/work.nix`
> - Removal of `slack` MCP entry in `modules/ai/mcp/work.nix`
> - New `<important if>` block in `modules/ai/instructions/INSTRUCTIONS.md` forbidding the "rationalize-and-proceed under ambiguity" anti-pattern (with the canonical bad example quoted verbatim)
> - Verified post-`switch`: CLI on PATH, skill discoverable, MCP gone, INSTRUCTIONS.md deployed to all harness targets
>
> **Estimated Effort**: Short (6 file edits + 1 rebuild + 1 auth bootstrap)
> **Parallel Execution**: YES — 2 waves (6 parallel edits, then integration)
> **Critical Path**: T1 (flake input) → T2-T6 (parallel file edits) → T7 (build + verify) → F1-F4 → user okay

---

## Context

### Original Request

> "Replace the slack MCP with https://github.com/stablyai/agent-slack — then also install the skills for the CLI"

### Interview Summary

**Key Discussions**:

- **Reframe accepted**: agent-slack is a CLI + skill, NOT an MCP server. The replacement model is: remove remote MCP, install CLI as a Nix-managed package, install the shipped agent skill.
- **Scope**: Work host only (matches current Slack MCP placement).
- **CLI install method**: Nix flake input (`github:stablyai/agent-slack`) → expose `packages.default` via a dedicated package module.
- **Skill source**: Reuse the same `agent-slack` flake input as the skill-source path (`agent-skills-nix` accepts both real flakes and `flake = false` inputs — both expose `.outPath`).
- **Test strategy**: Agent QA only (no automated tests for nix config). Final verification wave includes 4 parallel reviewers.

**Research Findings**:

- `agent-skills-nix.lib.resolveSourceRoot` uses `inputs.${name}.outPath` — works for real flakes and `flake = false` alike (validated by Metis from `Kyure-A/agent-skills-nix/lib/default.nix`).
- agent-slack ships `skills/agent-slack/SKILL.md` with skill id `agent-slack` — no collision with existing `skills.enable` lists.
- `/Applications/Slack.app` is installed and `~/Library/Application Support/Slack/Cookies` exists — `agent-slack auth import-desktop` precondition is satisfied.
- Existing canonical pattern for external-flake-packages: `modules/home-manager/packages/agenix/default.nix:7` uses `home.packages = [ inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default ];` — referenced via `(pkg "agenix")` in `hosts/work.nix:31`.
- `.mcp.json` (project-local) does not reference slack — no cleanup needed there.
- `mkHost.nix:59` passes `inputs` via `extraSpecialArgs`, so package modules receive `inputs` as expected.

### Metis Review

**Identified Gaps** (addressed):

- **Critical**: Initial draft proposed inlining `inputs.agent-slack.packages...` in `hosts/work.nix`. Repo convention uses a dedicated package module at `modules/home-manager/packages/{name}/default.nix`. **Resolution**: Plan now creates the dedicated module, matching `agenix`.
- **Auto-resolved**: Override only `inputs.nixpkgs.follows = "nixpkgs"` on the new input (matches all other inputs except `llm-agents` which preserves its own nixpkgs for binary cache compatibility). Do NOT override `flake-utils` — agent-slack uses it internally and no other repo input does this either.
- **Validated**: All assumptions verified — `agent-skills-nix` accepts real flake input, skill files exist, no skill ID conflict, no other slack references in repo.

---

## Work Objectives

### Core Objective

Migrate the work host's Slack tooling from the hosted remote MCP (mcp.slack.com) to the stablyai/agent-slack CLI + agent skill, fully managed by Nix.

### Concrete Deliverables

- New flake input `agent-slack` in `flake.nix`
- New package module `modules/home-manager/packages/agent-slack/default.nix`
- `(pkg "agent-slack")` added to `hosts/work.nix`
- `agent-slack` skill source + `skills.enable` entry in `modules/ai/skills/work.nix`
- Removal of `slack` MCP entry in `modules/ai/mcp/work.nix`
- Anti-pattern rule appended to `modules/ai/instructions/INSTRUCTIONS.md` (rationalize-and-proceed forbidden, canonical example quoted)
- `flake.lock` updated to include the new input
- After `switch`: `agent-slack --version` returns v0.9.3+ from `/nix/store`
- After `switch`: skill discoverable at the agent-skills-nix output path (claude / codex / agents targets)
- After `switch`: `agent-slack auth import-desktop` completes successfully (or user is shown the post-install instruction)
- After `switch`: the new INSTRUCTIONS.md block is present in the harness deploy paths (claude-code, codex, opencode all read this file)

### Definition of Done

- [ ] `nix flake check` passes
- [ ] `darwin-rebuild build --flake .` succeeds
- [ ] `which agent-slack` returns a `/nix/store/*-agent-slack-*/bin/agent-slack` path
- [ ] `agent-slack --help` prints the command map
- [ ] Skill SKILL.md is readable under the agent-skills-nix output directory (claude target at minimum)
- [ ] `grep -rn "mcp.slack.com\|slack = {" modules/ai/` returns zero matches
- [ ] All 4 final-wave reviewers (F1-F4) return APPROVE
- [ ] User explicitly says "okay" before marking work complete

### Must Have

- agent-slack CLI on PATH for the work-host user (matthewthomas)
- agent-slack skill discoverable by claude-code, codex, and opencode (all three targets are enabled in `modules/ai/skills/default.nix:64-68`)
- Old Slack remote-MCP entry completely removed (not commented)
- Single flake input (`agent-slack`) serves both CLI package AND skill source
- Nix-managed install — no `npm i -g`, no `curl | sh`

### Must NOT Have (Guardrails)

- **No** inline `inputs.agent-slack.packages...` in `hosts/work.nix` (use the dedicated module pattern)
- **No** `flake = false` on the `agent-slack` input — it's a real flake, treat it as such
- **No** override of `agent-slack.inputs.flake-utils.follows` (no other input does this; agent-slack is fine with its own flake-utils)
- **No** changes to the personal host (`hosts/personal.nix`, `modules/ai/*/personal.nix`) — scope is work only
- **No** changes to agenix / secrets — agent-slack uses Slack Desktop session auth, no API token needed
- **No** modifications to the agent-slack repo itself (treat as upstream, pinned via flake)
- **No** modifications to `modules/ai/skills/default.nix` (base) — the new skill is work-only, goes in `modules/ai/skills/work.nix`
- **No** refactoring of unrelated modules while we're here (skills module, MCP module, host file) — make only the additions/removals required
- **No** stub / placeholder commits — every commit must build cleanly

---

## Verification Strategy (MANDATORY)

> **ZERO HUMAN INTERVENTION** for verification (except the final "okay"). The executing agent runs every check, captures evidence, and reports.

### Test Decision

- **Infrastructure exists**: NO (pure Nix config; no unit-test framework for this concern)
- **Automated tests**: NONE — agent-executed verification only
- **Framework**: N/A
- **Note**: Verification relies entirely on `nix flake check`, `darwin-rebuild build`, `switch`, and post-switch shell assertions. Evidence saved to `.sisyphus/evidence/`.

### QA Policy

Every task includes agent-executed QA scenarios using these tools:

- **File edits**: Bash (`cat`, `grep`, `nix eval`) — verify expected content is in the file
- **Build**: Bash (`nix flake check`, `darwin-rebuild build --flake .`) — verify nix evaluates cleanly
- **Post-switch**: Bash (`which`, `--version`, `--help`, `ls`, `stat`) — verify CLI on PATH and skill files present
- **Auth bootstrap**: interactive_bash (tmux) — verify `agent-slack auth import-desktop` runs to completion

Evidence saved to `.sisyphus/evidence/task-{N}-{scenario-slug}.{txt|log}`.

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Foundation + Edits — all parallel, T1 must complete before others can be evaluated by nix, but text edits are independent):
├── T1: Add `agent-slack` flake input to flake.nix                                         [quick]
├── T2: Create modules/home-manager/packages/agent-slack/default.nix                       [quick]
├── T3: Wire (pkg "agent-slack") into hosts/work.nix packages list                         [quick]
├── T4: Add agent-slack skill source + enable in modules/ai/skills/work.nix                [quick]
├── T5: Remove `slack` entry from modules/ai/mcp/work.nix                                  [quick]
└── T6: Append "rationalize-and-proceed" anti-pattern rule to modules/ai/instructions/INSTRUCTIONS.md  [quick]

Wave 2 (Integration — after all edits done):
└── T7: nix flake check → darwin-rebuild build → switch → verify CLI + skill → auth import-desktop  [unspecified-high]

Wave FINAL (4 parallel reviews, then explicit user okay):
├── F1: Plan compliance audit                                   [oracle]
├── F2: Code quality review (nix-specific: statix, formatting, conventions)  [unspecified-high]
├── F3: Real manual QA (run CLI commands, inspect skill, confirm MCP gone)  [unspecified-high]
└── F4: Scope fidelity (no unintended diffs, no personal-host changes)  [deep]
→ Present results → Get explicit user okay
```

**Critical Path**: T1 → T2-T6 → T7 → F1-F4 → user okay
**Parallel Speedup**: ~50% (Wave 1 edits parallel)
**Max Concurrent**: 6 (Wave 1)

### Dependency Matrix

- **T1**: depends on — / blocks T2, T3, T4, T7 (text-edit-only; T2-T5 can be authored in parallel but won't evaluate until T1 lands)
- **T2**: depends on T1 (uses `inputs.agent-slack`) / blocks T3, T7
- **T3**: depends on T2 (references package module path) / blocks T7
- **T4**: depends on T1 (uses `inputs.agent-slack` as skill source name) / blocks T7
- **T5**: depends on — (independent removal) / blocks T7
- **T6**: depends on — (independent docs append; touches a non-nix file) / blocks T7 only loosely (T7 doesn't need INSTRUCTIONS.md to build, but the final reviewers verify it)
- **T7**: depends on T1, T2, T3, T4, T5, T6 / blocks F1-F4
- **F1-F4**: depend on T7 / blocks final user-okay

### Agent Dispatch Summary

- **Wave 1**: 6 tasks, all `quick` (Sisyphus-Junior)
- **Wave 2**: 1 task, `unspecified-high` (build + integrate + verify + auth-bootstrap is non-trivial)
- **Wave FINAL**: 4 reviewers — `oracle`, `unspecified-high`, `unspecified-high`, `deep`

---

## TODOs

- [x] 1. Add `agent-slack` flake input to `flake.nix`

  **What to do**:
  - Open `flake.nix`.
  - Add a new flake input after the `agent-skills-nix` block (currently `flake.nix:25-26`), following the exact same style as agenix and agent-skills-nix:
    ```nix
    agent-slack.url = "github:stablyai/agent-slack";
    agent-slack.inputs.nixpkgs.follows = "nixpkgs";
    ```
  - Run `nix flake lock` (or `nix flake update --update-input agent-slack` on newer nix) to record the input in `flake.lock`.
  - Stage both `flake.nix` and `flake.lock` together — they must move as a pair.

  **Must NOT do**:
  - Do NOT set `flake = false` — agent-slack IS a real flake (verified: `flake.nix` exposes `packages.default = agent-slack`).
  - Do NOT override `flake-utils.follows` — no other input in this repo does this, and agent-slack uses its own flake-utils internally without issue.
  - Do NOT place this input in the `flake = false` group (lines 28-101) — place it near the real-flake inputs (after line 26, before line 28).
  - Do NOT bump or touch any other input's revision.

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Single-file text edit (~2 lines added) + a lockfile-refresh command. No design decisions.
  - **Skills**: [`nix`, `nix-darwin`]
    - `nix`: Idiomatic Nix patterns — ensures the new input is added without `with`/`rec` and respects formatting conventions.
    - `nix-darwin`: Flake input management for this specific repo (mkHost builder, host files).
  - **Skills Evaluated but Omitted**:
    - `home-manager`: Skill applies when adding tools/configuring apps. This task adds a flake input only — no home-manager module is touched here.

  **Parallelization**:
  - **Can Run In Parallel**: YES (text-only edit; doesn't depend on other Wave-1 edits)
  - **Parallel Group**: Wave 1 (with T2, T3, T4, T5)
  - **Blocks**: T2, T3, T4 (they reference `inputs.agent-slack`), and T7 (build)
  - **Blocked By**: None — can start immediately

  **References**:

  **Pattern References** (existing code to follow):
  - `flake.nix:22-23` — `agenix.url = "github:ryantm/agenix"; agenix.inputs.nixpkgs.follows = "nixpkgs";` — exact two-line style for a real flake input.
  - `flake.nix:25-26` — `agent-skills-nix.url = "github:Kyure-A/agent-skills-nix"; agent-skills-nix.inputs.nixpkgs.follows = "nixpkgs";` — adjacent input; insert directly after this block.
  - `flake.nix:16-18` — `llm-agents` is the COUNTER-EXAMPLE: it explicitly does NOT follow nixpkgs because it ships pre-built binaries via cache.numtide.com. agent-slack has no such constraint, so we DO want it to follow.

  **External References**:
  - agent-slack upstream `flake.nix`: https://github.com/stablyai/agent-slack/blob/main/flake.nix — confirms `packages.${system}.default` is exposed via `flake-utils.lib.eachDefaultSystem`.

  **WHY Each Reference Matters**:
  - The `agenix` and `agent-skills-nix` patterns establish that real-flake inputs in this repo get `nixpkgs.follows` to share evaluation. We follow that convention.
  - The `llm-agents` counter-example demonstrates when NOT to follow nixpkgs (binary cache pinning) — agent-slack does not match that scenario.
  - The upstream `flake.nix` confirms that `inputs.agent-slack.packages.${system}.default` will resolve to a usable derivation.

  **Acceptance Criteria**:
  - [ ] `grep -c 'agent-slack' flake.nix` returns ≥ 2 (input url + follows line)
  - [ ] `flake.lock` contains a node named `agent-slack` with a `rev` field
  - [ ] `nix eval --raw .#inputs.agent-slack.packages.aarch64-darwin.default.name 2>&1` returns `agent-slack` (or a derivation name containing it)

  **QA Scenarios**:

  ```
  Scenario: Flake input is present and well-formed
    Tool: Bash
    Preconditions: flake.nix edited per "What to do"
    Steps:
      1. Run: grep -n 'agent-slack' flake.nix
      2. Assert: two consecutive lines around line ~27-28, first containing `agent-slack.url = "github:stablyai/agent-slack";`, second containing `agent-slack.inputs.nixpkgs.follows = "nixpkgs";`
      3. Assert: NO line contains `flake = false;` adjacent to agent-slack
    Expected Result: 2 matches, both inside the `inputs = { ... };` block (above line 103)
    Failure Indicators: missing input, wrong URL, `flake = false` set, placement inside the source-only group
    Evidence: .sisyphus/evidence/task-1-flake-grep.log

  Scenario: flake.lock updated
    Tool: Bash
    Preconditions: After running `nix flake lock`
    Steps:
      1. Run: nix flake metadata --json 2>&1 | jq -r '.locks.nodes."agent-slack".locked.rev'
      2. Assert: a 40-char hex SHA is returned (not "null" / empty)
    Expected Result: A commit SHA from github.com/stablyai/agent-slack
    Evidence: .sisyphus/evidence/task-1-lockfile-rev.log

  Scenario: Real flake (not flake = false) resolves correctly
    Tool: Bash
    Preconditions: flake.nix + flake.lock updated
    Steps:
      1. Run: nix eval --raw .#inputs.agent-slack.packages.aarch64-darwin.default.name 2>&1 | tee .sisyphus/evidence/task-1-eval.log
      2. Assert: output contains "agent-slack" and exit code is 0
    Expected Result: A derivation name like `agent-slack-0.9.3` (exact version may vary)
    Failure Indicators: error `attribute 'packages' missing` (would mean flake=false was set), or `attribute 'aarch64-darwin' missing` (would mean nixpkgs.follows broke something)
    Evidence: .sisyphus/evidence/task-1-eval.log
  ```

  **Evidence to Capture**:
  - [ ] `.sisyphus/evidence/task-1-flake-grep.log`
  - [ ] `.sisyphus/evidence/task-1-lockfile-rev.log`
  - [ ] `.sisyphus/evidence/task-1-eval.log`

  **Commit**: NO (groups with T2-T5 in a single commit after T7 verifies the build)

- [x] 2. Create `modules/home-manager/packages/agent-slack/default.nix`

  **What to do**:
  - Create the directory: `modules/home-manager/packages/agent-slack/`.
  - Create file `modules/home-manager/packages/agent-slack/default.nix` with this exact content:
    ```nix
    {
      inputs,
      pkgs,
      ...
    }:
    {
      home.packages = [ inputs.agent-slack.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    }
    ```

  **Must NOT do**:
  - Do NOT add `programs.agent-slack` config — agent-slack does not have a home-manager program module.
  - Do NOT add wrappers, activation hooks, or `home.file` entries for skill files (the skill is installed via the separate `agent-skills-nix` mechanism in T4).
  - Do NOT use `pkgs.callPackage` to rebuild from source — we want the upstream-built derivation.
  - Do NOT pin a version inside the module — version comes from `flake.lock`.
  - Do NOT add any imports or `with` statements.

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: New file with 7 lines, copying a known-good template (agenix). Mechanical work.
  - **Skills**: [`home-manager`, `nix`]
    - `home-manager`: Module patterns for installing tools. This is the canonical "external-flake-package-as-home-manager-module" pattern.
    - `nix`: Idiomatic style — no `with`, no `rec`, proper attrset formatting.
  - **Skills Evaluated but Omitted**:
    - `nix-darwin`: Skill applies to system-level config (system defaults, flake inputs, host files). This task creates a home-manager module — doesn't overlap.

  **Parallelization**:
  - **Can Run In Parallel**: YES (independent new file)
  - **Parallel Group**: Wave 1 (with T1, T3, T4, T5)
  - **Blocks**: T3 (which references the directory via `(pkg "agent-slack")`), T7 (build)
  - **Blocked By**: T1 in spirit (the module references `inputs.agent-slack`), but the FILE can be authored in parallel — only the build (T7) requires both done

  **References**:

  **Pattern References**:
  - `modules/home-manager/packages/agenix/default.nix:1-8` — **exact template to clone**. The new file should be a 1:1 structural copy with only the input name changed (`agenix` → `agent-slack`).

  **API/Type References**:
  - `lib/mkHost.nix:59` — `extraSpecialArgs = { inherit settings inputs applicationNames; };` — confirms that `inputs` is passed to every home-manager module, so `{ inputs, pkgs, ... }:` is valid.
  - `pkgs.stdenv.hostPlatform.system` — standard nixpkgs expression that resolves to `aarch64-darwin` on this machine, used to index into the per-system packages output.

  **External References**:
  - agent-slack flake outputs (https://github.com/stablyai/agent-slack/blob/main/flake.nix): `packages = { inherit agent-slack; default = agent-slack; };` — confirms `.default` is the right accessor.

  **WHY Each Reference Matters**:
  - The agenix template is the canonical example of this exact pattern (external-flake → home-manager package). Copying it byte-for-byte (with name substitution) avoids any structural drift.
  - The `mkHost.nix:59` reference proves the `inputs` argument will be populated — without that, the module would fail to evaluate.
  - The upstream flake reference confirms that `.packages.${system}.default` is the correct path (vs. `.packages.${system}.agent-slack`, which would also work but is less canonical).

  **Acceptance Criteria**:
  - [ ] File `modules/home-manager/packages/agent-slack/default.nix` exists
  - [ ] Content matches the agenix template structurally (3-line attr-args, `home.packages = [ inputs.X.packages.${pkgs.stdenv.hostPlatform.system}.default ];`)
  - [ ] `nix-instantiate --parse modules/home-manager/packages/agent-slack/default.nix` exits 0
  - [ ] `treefmt --no-cache --fail-on-change modules/home-manager/packages/agent-slack/default.nix` exits 0
  - [ ] `statix check modules/home-manager/packages/agent-slack/default.nix` reports zero issues

  **QA Scenarios**:

  ```
  Scenario: File exists with correct content
    Tool: Bash
    Preconditions: file created per "What to do"
    Steps:
      1. Run: cat modules/home-manager/packages/agent-slack/default.nix | tee .sisyphus/evidence/task-2-file.log
      2. Assert: output contains `inputs.agent-slack.packages.${pkgs.stdenv.hostPlatform.system}.default`
      3. Assert: output contains the line `home.packages = [`
      4. Assert: file has between 6 and 10 lines (matches agenix's ~8)
    Expected Result: Content structurally identical to agenix module
    Failure Indicators: file missing, content uses `with pkgs;`, uses `inputs.agent-slack.packages.aarch64-darwin.default` (hardcoded system), includes extra imports
    Evidence: .sisyphus/evidence/task-2-file.log

  Scenario: Nix parses the file
    Tool: Bash
    Preconditions: file created
    Steps:
      1. Run: nix-instantiate --parse modules/home-manager/packages/agent-slack/default.nix 2>&1 | tee .sisyphus/evidence/task-2-parse.log
      2. Assert: exit code 0 and output is a valid AST dump
    Expected Result: Parser accepts the file
    Evidence: .sisyphus/evidence/task-2-parse.log

  Scenario: Style is clean (statix + treefmt)
    Tool: Bash
    Preconditions: file created
    Steps:
      1. Run: statix check modules/home-manager/packages/agent-slack/default.nix 2>&1 | tee .sisyphus/evidence/task-2-statix.log
      2. Run: treefmt --no-cache --fail-on-change modules/home-manager/packages/agent-slack/default.nix 2>&1 | tee .sisyphus/evidence/task-2-treefmt.log
      3. Assert: both exit 0 (zero issues, zero diff)
    Expected Result: Both linters pass with no changes required
    Evidence: .sisyphus/evidence/task-2-statix.log, .sisyphus/evidence/task-2-treefmt.log
  ```

  **Evidence to Capture**:
  - [ ] `.sisyphus/evidence/task-2-file.log`
  - [ ] `.sisyphus/evidence/task-2-parse.log`
  - [ ] `.sisyphus/evidence/task-2-statix.log`
  - [ ] `.sisyphus/evidence/task-2-treefmt.log`

  **Commit**: NO (groups with T1, T3-T5 after T7)

- [x] 3. Wire `(pkg "agent-slack")` into `hosts/work.nix` packages list

  **What to do**:
  - Open `hosts/work.nix`.
  - In the `packages = [ ... ];` list (currently `hosts/work.nix:30-60`), add `(pkg "agent-slack")` in alphabetical order. The list is mostly alphabetical with minor exceptions (delta after devenv). Insert between `(pkg "aerospace")` (line 32) and `(pkg "bat")` (line 33), so the line numbering after the edit is:
    ```nix
    (pkg "agenix")
    (pkg "aerospace")
    (pkg "agent-slack")   # NEW
    (pkg "bat")
    ```
  - That's a single-line addition. Make no other changes to the file.

  **Must NOT do**:
  - Do NOT touch `hosts/personal.nix` (scope is work only).
  - Do NOT touch the `applications`, `ai`, or `darwinModules` arrays in `hosts/work.nix`.
  - Do NOT add `(pkg "agent-slack")` more than once.
  - Do NOT introduce any imports/let-bindings/comments around the new line.

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Single-line list insertion.
  - **Skills**: [`nix-darwin`]
    - `nix-darwin`: Host file management (mkHost builder, packages list pattern). The skill describes exactly how the `packages = [ (pkg "X") ];` pattern works.
  - **Skills Evaluated but Omitted**:
    - `nix`: Idiomatic-Nix concerns don't apply to a list-insertion in pre-formatted code.
    - `home-manager`: This task wires the package via `(pkg "name")`; the home-manager module itself was created in T2.

  **Parallelization**:
  - **Can Run In Parallel**: YES (different file from T1, T2, T4, T5)
  - **Parallel Group**: Wave 1
  - **Blocks**: T7 (build)
  - **Blocked By**: T2 in spirit (the module path must exist), but file edits can be authored in parallel — only the build (T7) requires both

  **References**:

  **Pattern References**:
  - `hosts/work.nix:31` — `(pkg "agenix")` — exact placement style and alphabetical order
  - `hosts/work.nix:1-2` — `app = name: ../modules/home-manager/applications/${name};` and `pkg = name: ../modules/home-manager/packages/${name};` — the helper functions that resolve `"name"` to the module directory
  - `hosts/work.nix:30-60` — the full packages list for ordering context

  **API/Type References**:
  - `lib/mkHost.nix:60` — `sharedModules = applications ++ packages ++ ai;` — confirms the `packages` list is merged into home-manager's shared modules. Adding the entry here is sufficient to install agent-slack on the work host.

  **WHY Each Reference Matters**:
  - The `(pkg "agenix")` line at 31 is the exact precedent: an external-flake package referenced via the `pkg` helper. Our new line is structurally identical, just at a different alphabetical position.
  - The `pkg` helper definition shows we don't need to write any path machinery — passing `"agent-slack"` is sufficient.
  - `mkHost.nix:60` confirms the wiring is complete (no other file needs updating to make the package install).

  **Acceptance Criteria**:
  - [ ] `grep -n 'agent-slack' hosts/work.nix` returns exactly 1 match
  - [ ] The match is inside the `packages = [ ... ];` block (line range 30-60)
  - [ ] No other lines in `hosts/work.nix` are modified (verifiable via `git diff hosts/work.nix` showing exactly 1 added line)
  - [ ] `treefmt --no-cache --fail-on-change hosts/work.nix` exits 0

  **QA Scenarios**:

  ```
  Scenario: Exact one-line insertion
    Tool: Bash
    Preconditions: hosts/work.nix edited per "What to do"
    Steps:
      1. Run: git diff --unified=0 hosts/work.nix | tee .sisyphus/evidence/task-3-diff.log
      2. Assert: diff shows exactly 1 added line containing `(pkg "agent-slack")`
      3. Assert: zero removed lines
    Expected Result: Single-line addition, nothing else changed
    Failure Indicators: more than 1 added line, any removed lines, edits outside the packages block
    Evidence: .sisyphus/evidence/task-3-diff.log

  Scenario: Entry resolves to a real package module
    Tool: Bash
    Preconditions: T2 done (module file exists), T3 done (entry added)
    Steps:
      1. Run: test -f modules/home-manager/packages/agent-slack/default.nix && echo OK | tee .sisyphus/evidence/task-3-module-exists.log
      2. Assert: prints "OK" — the path `(pkg "agent-slack")` resolves to is real
    Expected Result: Module file is present at the expected location
    Evidence: .sisyphus/evidence/task-3-module-exists.log

  Scenario: Personal host untouched (negative check)
    Tool: Bash
    Preconditions: T3 edit applied
    Steps:
      1. Run: git diff hosts/personal.nix | tee .sisyphus/evidence/task-3-personal-untouched.log
      2. Assert: empty output (no changes)
    Expected Result: Personal host is bit-for-bit identical to its previous state
    Evidence: .sisyphus/evidence/task-3-personal-untouched.log
  ```

  **Evidence to Capture**:
  - [ ] `.sisyphus/evidence/task-3-diff.log`
  - [ ] `.sisyphus/evidence/task-3-module-exists.log`
  - [ ] `.sisyphus/evidence/task-3-personal-untouched.log`

  **Commit**: NO (groups with T1, T2, T4, T5 after T7)

- [x] 4. Wire `agent-slack` skill source + enable in `modules/ai/skills/work.nix`

  **What to do**:
  - Open `modules/ai/skills/work.nix`.
  - Inside `programs.agent-skills.sources = { ... };` (currently lines 3-21), add a new entry. Place it at the end of the sources block (after `chrome-devtools-mcp`, before the closing `};` of `sources`):
    ```nix
    agent-slack = {
      input = "agent-slack";
      subdir = "skills";
    };
    ```
  - Inside `skills.enable = [ ... ];` (currently lines 22-40), add `"agent-slack"` at the end of the list (after `"troubleshooting"`).
  - Make no other changes.

  **Must NOT do**:
  - Do NOT modify `modules/ai/skills/default.nix` (base) — the base is shared across hosts.
  - Do NOT modify `modules/ai/skills/personal.nix` — scope is work only.
  - Do NOT add a `filter.maxDepth` entry — agent-slack's `skills/agent-slack/` is a single, well-scoped skill, not a directory of many skills (filter is only used for repos like worktrunk that bundle nested content).
  - Do NOT add `idPrefix` — the skill is named `agent-slack` and that's the desired id.
  - Do NOT reorder existing entries.

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Two small additions to an existing config file — one source entry (4 lines) and one list element (1 line).
  - **Skills**: [`nix`, `home-manager`]
    - `nix`: Idiomatic style for attrset additions and list elements.
    - `home-manager`: The `programs.agent-skills` module is a home-manager program — this skill explains the pattern.
  - **Skills Evaluated but Omitted**:
    - `nix-darwin`: System-level concerns; this task is purely home-manager config.

  **Parallelization**:
  - **Can Run In Parallel**: YES (different file from T1, T2, T3, T5)
  - **Parallel Group**: Wave 1
  - **Blocks**: T7 (build)
  - **Blocked By**: T1 in spirit (the `"agent-slack"` input name must exist), but file authoring can run in parallel

  **References**:

  **Pattern References**:
  - `modules/ai/skills/work.nix:4-7` — `pup = { input = "pup-skills"; subdir = "skills"; };` — closest analog (single skill source, no filter)
  - `modules/ai/skills/work.nix:8-11` — `linear-cli = { input = "linear-cli-skills"; subdir = "skills"; };` — another single-source example
  - `modules/ai/skills/work.nix:22-40` — the existing `skills.enable` list (alphabetical-ish, append at end is fine)

  **API/Type References**:
  - `modules/ai/skills/default.nix:6` — `imports = [ inputs.agent-skills-nix.homeManagerModules.default ];` — confirms the module is already imported in the base; we just add a source + enable in the work overlay.
  - `agent-skills-nix.lib.resolveSourceRoot` (verified by Metis): accepts `input = "name"` and resolves via `inputs.${name}.outPath`. Works for both real flakes and `flake = false` inputs.
  - `agent-skills-nix` schema: `sources.{name} = { input, subdir, idPrefix?, filter? };` or `sources.{name} = { path; };`

  **WHY Each Reference Matters**:
  - The `pup` and `linear-cli` entries are the structural template: 3-key attrset with `input` (flake name) and `subdir` (path within input). agent-slack matches: input is `agent-slack`, subdir is `skills` (since the skill lives at `skills/agent-slack/`).
  - The `default.nix:6` import means we don't need to import anything in `work.nix` — the base does it.
  - Metis's verification of `resolveSourceRoot` confirms the user's decision to reuse the real flake input (vs. adding a separate `flake = false`) will work.

  **Acceptance Criteria**:
  - [ ] `grep -c 'agent-slack' modules/ai/skills/work.nix` returns 2 (one in sources, one in skills.enable)
  - [ ] `grep -A2 'agent-slack = {' modules/ai/skills/work.nix` shows the 3-key attrset with `input = "agent-slack";` and `subdir = "skills";`
  - [ ] `git diff modules/ai/skills/default.nix` is empty
  - [ ] `git diff modules/ai/skills/personal.nix` is empty
  - [ ] `treefmt --no-cache --fail-on-change modules/ai/skills/work.nix` exits 0
  - [ ] `statix check modules/ai/skills/work.nix` reports zero issues

  **QA Scenarios**:

  ```
  Scenario: Source entry and enable list both updated correctly
    Tool: Bash
    Preconditions: file edited per "What to do"
    Steps:
      1. Run: grep -n 'agent-slack' modules/ai/skills/work.nix | tee .sisyphus/evidence/task-4-grep.log
      2. Assert: exactly 2 matches — one in the `sources = { ... }` block, one in `skills.enable = [ ... ]`
      3. Assert: the source entry contains `input = "agent-slack";` and `subdir = "skills";`
      4. Assert: the enable entry is the exact string `"agent-slack"` (no prefix, no path)
    Expected Result: Two well-formed references to agent-slack
    Failure Indicators: only 1 match (source missing or enable missing), wrong subdir value, idPrefix accidentally added
    Evidence: .sisyphus/evidence/task-4-grep.log

  Scenario: Base and personal skills configs untouched
    Tool: Bash
    Preconditions: T4 edit applied
    Steps:
      1. Run: git diff modules/ai/skills/default.nix modules/ai/skills/personal.nix | tee .sisyphus/evidence/task-4-untouched.log
      2. Assert: empty output (no diff)
    Expected Result: Only modules/ai/skills/work.nix is modified
    Evidence: .sisyphus/evidence/task-4-untouched.log

  Scenario: Lint and format pass
    Tool: Bash
    Preconditions: file edited
    Steps:
      1. Run: statix check modules/ai/skills/work.nix 2>&1 | tee .sisyphus/evidence/task-4-statix.log
      2. Run: treefmt --no-cache --fail-on-change modules/ai/skills/work.nix 2>&1 | tee .sisyphus/evidence/task-4-treefmt.log
      3. Assert: both exit 0
    Expected Result: Clean lint + format
    Evidence: .sisyphus/evidence/task-4-statix.log, .sisyphus/evidence/task-4-treefmt.log
  ```

  **Evidence to Capture**:
  - [ ] `.sisyphus/evidence/task-4-grep.log`
  - [ ] `.sisyphus/evidence/task-4-untouched.log`
  - [ ] `.sisyphus/evidence/task-4-statix.log`
  - [ ] `.sisyphus/evidence/task-4-treefmt.log`

  **Commit**: NO (groups with T1, T2, T3, T5 after T7)

- [x] 5. Remove the `slack` MCP entry from `modules/ai/mcp/work.nix`

  **What to do**:
  - Open `modules/ai/mcp/work.nix`.
  - Delete the entire `slack` entry, currently at lines 20-27 (inclusive):
    ```nix
    slack = {
      type = "remote";
      url = "https://mcp.slack.com/mcp";
      oauth = {
        clientId = "1601185624273.8899143856786";
        callbackPort = 3118;
      };
    };
    ```
  - After deletion, the file should have 21 lines (down from 29) and the `chrome-devtools` entry (which used to end with `};` on line 19) becomes the last entry in `programs.mcp.servers`.
  - Remove any leading blank line between `chrome-devtools` and the closing `};` of `servers` if one remains.

  **Must NOT do**:
  - Do NOT comment out the entry — delete it cleanly.
  - Do NOT modify the `notion`, `incident-io`, or `chrome-devtools` entries.
  - Do NOT modify `modules/ai/mcp/default.nix` (base) — it doesn't contain slack anyway, but be explicit.
  - Do NOT leave the OAuth `clientId` or `callbackPort` numbers anywhere else in the repo (search to verify cleanup).

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: 8-line deletion in a single file.
  - **Skills**: [`nix`]
    - `nix`: Idiomatic style — ensures clean deletion without leaving stray whitespace, blank lines, or syntactic issues.
  - **Skills Evaluated but Omitted**:
    - `home-manager`: No new module is added; this is purely a removal.
    - `nix-darwin`: System-level concerns don't apply.

  **Parallelization**:
  - **Can Run In Parallel**: YES (independent file from T1-T4)
  - **Parallel Group**: Wave 1
  - **Blocks**: T7 (build), F3 (which verifies MCP is gone), F4 (scope fidelity)
  - **Blocked By**: None

  **References**:

  **Pattern References**:
  - `modules/ai/mcp/work.nix:20-27` — the exact lines to delete (verbatim block)
  - `modules/ai/mcp/work.nix:12-19` — the `chrome-devtools` entry that will become the last entry; verify the closing `};` and the outer servers-closing `};` stay correct
  - `modules/ai/mcp/default.nix:9-34` — the base `programs.mcp.servers` block; shows the canonical formatting (4-space indent inside servers, 2-space at module level)

  **API/Type References**:
  - `programs.mcp.servers.<name>` — set-like; removing an entry has no side effects on other entries.

  **WHY Each Reference Matters**:
  - The exact line range tells the executor precisely what to remove — no ambiguity.
  - The base default.nix shows the formatting convention so the closing braces stay clean.
  - Confirming `programs.mcp.servers` is a set with no inter-entry dependencies means we can safely delete.

  **Acceptance Criteria**:
  - [ ] `grep -n 'slack' modules/ai/mcp/work.nix` returns zero matches
  - [ ] `grep -rn 'mcp.slack.com' modules/ai/` returns zero matches
  - [ ] `grep -rn '1601185624273' .` returns zero matches (OAuth client id fully removed)
  - [ ] `wc -l < modules/ai/mcp/work.nix` returns 21 (was 29, removed 8 lines)
  - [ ] `nix-instantiate --parse modules/ai/mcp/work.nix` exits 0
  - [ ] `treefmt --no-cache --fail-on-change modules/ai/mcp/work.nix` exits 0

  **QA Scenarios**:

  ```
  Scenario: Slack entry fully removed
    Tool: Bash
    Preconditions: file edited per "What to do"
    Steps:
      1. Run: grep -n 'slack\|mcp.slack.com\|1601185624273' modules/ai/mcp/work.nix | tee .sisyphus/evidence/task-5-grep.log
      2. Assert: zero matches (file is grep-clean of slack-related strings)
    Expected Result: Empty grep output
    Failure Indicators: any remaining `slack`, URL, or OAuth client id
    Evidence: .sisyphus/evidence/task-5-grep.log

  Scenario: Other entries preserved
    Tool: Bash
    Preconditions: T5 done
    Steps:
      1. Run: grep -c 'notion\|incident-io\|chrome-devtools' modules/ai/mcp/work.nix | tee .sisyphus/evidence/task-5-others.log
      2. Assert: ≥ 3 matches (notion, incident-io, chrome-devtools all present)
    Expected Result: All other MCP entries intact
    Failure Indicators: accidental deletion of adjacent entries
    Evidence: .sisyphus/evidence/task-5-others.log

  Scenario: Repo-wide cleanup verified
    Tool: Bash
    Preconditions: T5 done
    Steps:
      1. Run: grep -rn 'mcp.slack.com\|1601185624273.8899143856786' . --exclude-dir=.git --exclude-dir=.sisyphus 2>&1 | tee .sisyphus/evidence/task-5-repowide.log
      2. Assert: zero matches outside of .git / .sisyphus (the plan + draft in .sisyphus reference these for documentation purposes; that's expected and excluded)
    Expected Result: No stray references anywhere in the live config
    Evidence: .sisyphus/evidence/task-5-repowide.log

  Scenario: File still parses as valid Nix
    Tool: Bash
    Preconditions: T5 done
    Steps:
      1. Run: nix-instantiate --parse modules/ai/mcp/work.nix 2>&1 | tee .sisyphus/evidence/task-5-parse.log
      2. Assert: exit code 0
    Expected Result: Valid Nix file after deletion
    Failure Indicators: stray comma, unmatched brace, invalid trailing blank line
    Evidence: .sisyphus/evidence/task-5-parse.log
  ```

  **Evidence to Capture**:
  - [ ] `.sisyphus/evidence/task-5-grep.log`
  - [ ] `.sisyphus/evidence/task-5-others.log`
  - [ ] `.sisyphus/evidence/task-5-repowide.log`
  - [ ] `.sisyphus/evidence/task-5-parse.log`

  **Commit**: NO (groups with T1-T4, T6 after T7)

- [x] 6. Append "rationalize-and-proceed" anti-pattern rule to `modules/ai/instructions/INSTRUCTIONS.md`

  **What to do**:
  - Open `modules/ai/instructions/INSTRUCTIONS.md`.
  - The file currently has 5 `<important if>` blocks (lines 5-9, 11-15, 17-21, 23-27, 29-33) and ends at line 33.
  - **Append** the following new block at the end of the file (a blank line separator after the existing `</important>` on line 33, then the new block). Do NOT modify any existing block.

  ```markdown
  <important if="you encounter ambiguity, edge cases, or seemingly conflicting rules in a project's AGENTS.md, CLAUDE.md, or similar instruction files">

  **Do not rationalize-and-proceed.** When a rule is unclear at the edges:

  1. **Default to the strict literal reading** of the rule. Edge cases resolve in favor of the rule.
  2. **If still genuinely ambiguous**, ask ONE focused question and stop. Do not act under a guessed interpretation.

  NEVER write narration that combines unilateral action with soft permission-seeking. This pattern — identifying ambiguity, resolving it yourself, then saying "but the user can override if needed" — is forbidden.

  Canonical bad example (do NOT do this):

  > "On the AGENTS.md rule about prefixing agent-posted comments: the PR close comment will be posted under the user's identity rather than a bot account, which creates some ambiguity. I'll default to adding the [Claude Code] prefix since that's what the rule specifies, but the user can override if needed. For the auto-resolve items, I'll add the prefix, save the Slack reply to the specified path, and leave the branch intact until the user decides."

  Why this is forbidden:

  - It identifies ambiguity, then resolves it unilaterally
  - It wraps the action in "but you can override" language to dodge commitment to either following or asking
  - It bundles multiple unrelated decisions ("for the auto-resolve items, I'll do A, B, and C") as a fait accompli
  - It reads like internal monologue posing as communication

  The correct alternatives:

  - **Follow strictly**: "The rule says prefix with [Claude Code]. Doing so." (No narration.)
  - **Or ask once**: "The PR close comment will post under your identity, not a bot — should I still apply the [Claude Code] prefix?" Then stop and wait.

  Never both, never bundled, never narrated.

  </important>
  ```

  - Note on indentation: the example shows the block with two-space indentation only because it's nested inside this plan's bullet point. **The block as written into INSTRUCTIONS.md must have ZERO leading indentation** — match the existing blocks at column 0. Remove the leading two spaces from every line of the snippet before writing.
  - Preserve the file's existing line-ending convention (LF) and add a single trailing newline at end of file.

  **Must NOT do**:
  - Do NOT modify any of the existing 5 `<important if>` blocks (lines 5-33 of the current file).
  - Do NOT reorder existing blocks.
  - Do NOT change the file header `# Global Instructions` or the introductory sentence.
  - Do NOT add backticks/code-fences around the quoted bad example (it's a blockquote `>`, not a code block — that's intentional, matches the surrounding tone).
  - Do NOT paraphrase or shorten the canonical bad example quote — it must appear verbatim so future agents can pattern-match it.
  - Do NOT remove the trailing newline at end of file.

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Append-only markdown edit (~25 lines added). No design decisions.
  - **Skills**: [`improve-claude-md`]
    - `improve-claude-md`: This file uses `<important if>` blocks to improve instruction adherence — exactly the pattern this skill describes. Ensures the new block fits the existing convention.
  - **Skills Evaluated but Omitted**:
    - `nix`, `home-manager`, `nix-darwin`: This task is pure markdown — no nix involvement.
    - `writing-skills`: That skill is for authoring new SKILLs (with frontmatter, etc.). This is an instructions-file edit, not a skill file.

  **Parallelization**:
  - **Can Run In Parallel**: YES (touches a different file from T1-T5)
  - **Parallel Group**: Wave 1 (with T1, T2, T3, T4, T5)
  - **Blocks**: T7 only loosely — T7's build doesn't depend on INSTRUCTIONS.md content, but F3/F4 verify this file post-switch.
  - **Blocked By**: None — can start immediately

  **References**:

  **Pattern References**:
  - `modules/ai/instructions/INSTRUCTIONS.md:5-9` — existing `<important if="you are looking up documentation, ...">` block, shows the canonical structure (one-line trigger condition, blank line, body, blank line, `</important>`).
  - `modules/ai/instructions/INSTRUCTIONS.md:29-33` — most recent block (git-machete); append directly after.
  - `modules/ai/instructions/INSTRUCTIONS.md:1-3` — file header; do not touch.

  **API/Type References**:
  - `<important if="...">` — this is a custom markup convention used by the `improve-claude-md` skill (referenced in `modules/ai/skills/work.nix:42`). It signals to AI harnesses that the enclosed instruction is high-priority and conditional. Format: opening tag with `if="<trigger phrase>"`, blank line, markdown body, blank line, `</important>` closing tag, blank line separator.

  **External References**:
  - Existing skill: `improve-claude-md` (from `humanlayer-skills` flake input) documents this pattern at https://github.com/humanlayer/skills/blob/main/plugins/improve-claude-md/skills/improve-claude-md/SKILL.md — confirms `<important if>` is the intended idiom for conditional instructions.

  **WHY Each Reference Matters**:
  - The existing 5 blocks establish the exact formatting convention (trigger phrasing, body style, list-vs-prose). Matching this convention ensures the new rule is parsed consistently by claude-code, codex, and opencode.
  - The `improve-claude-md` skill confirms the `<important if>` tag is intentional and the right tool for the job — not a markdown extension we should swap for a different syntax.
  - The header reference is a guardrail against accidental modification of file scaffolding.

  **Acceptance Criteria**:
  - [ ] `grep -c '^<important if=' modules/ai/instructions/INSTRUCTIONS.md` returns exactly 6 (was 5, gained 1)
  - [ ] `grep -F 'rationalize-and-proceed' modules/ai/instructions/INSTRUCTIONS.md` returns at least 1 match (the new block's body)
  - [ ] `grep -F "PR close comment will be posted under the user's identity" modules/ai/instructions/INSTRUCTIONS.md` returns exactly 1 match (the canonical bad example quote, verbatim)
  - [ ] `git diff modules/ai/instructions/INSTRUCTIONS.md` shows ONLY additions (zero `-` lines)
  - [ ] First 5 `<important if>` blocks are bit-for-bit identical to the pre-edit state (verifiable via `git diff` — only additions appear after line 33)
  - [ ] File ends with exactly one trailing newline (check with `tail -c 1 modules/ai/instructions/INSTRUCTIONS.md | xxd` showing `0a` and nothing after)
  - [ ] `treefmt --no-cache --fail-on-change modules/ai/instructions/INSTRUCTIONS.md` exits 0 (markdown formatter does not want to reformat)

  **QA Scenarios**:

  ```
  Scenario: New block appended verbatim and existing blocks untouched
    Tool: Bash
    Preconditions: INSTRUCTIONS.md edited per "What to do"
    Steps:
      1. Run: git diff modules/ai/instructions/INSTRUCTIONS.md | tee .sisyphus/evidence/task-6-diff.log
      2. Assert: diff contains ONLY `+` lines (no `-` lines) — block is purely appended
      3. Assert: diff contains `+<important if="you encounter ambiguity` (new block opening)
      4. Assert: diff contains `+> "On the AGENTS.md rule about prefixing agent-posted comments` (canonical example, verbatim, as a blockquote)
      5. Assert: diff contains `+</important>` near the end
    Expected Result: Pure append, no modifications to existing content
    Failure Indicators: any `-` line, modified existing block, paraphrased canonical quote, missing blockquote prefix `>`
    Evidence: .sisyphus/evidence/task-6-diff.log

  Scenario: Block count and unique strings are correct
    Tool: Bash
    Preconditions: edit applied
    Steps:
      1. Run: grep -c '^<important if=' modules/ai/instructions/INSTRUCTIONS.md | tee .sisyphus/evidence/task-6-count.log
      2. Assert: output is `6` (was 5)
      3. Run: grep -F "PR close comment will be posted under the user's identity" modules/ai/instructions/INSTRUCTIONS.md | wc -l | tee .sisyphus/evidence/task-6-quote.log
      4. Assert: output is `1`
      5. Run: grep -F 'rationalize-and-proceed' modules/ai/instructions/INSTRUCTIONS.md | wc -l | tee .sisyphus/evidence/task-6-key.log
      6. Assert: output is ≥ 1
    Expected Result: Counts match (6 blocks, 1 verbatim quote, ≥1 key term)
    Evidence: .sisyphus/evidence/task-6-count.log, .sisyphus/evidence/task-6-quote.log, .sisyphus/evidence/task-6-key.log

  Scenario: File parses cleanly as markdown (no broken tags)
    Tool: Bash
    Preconditions: edit applied
    Steps:
      1. Run: awk '/^<important if=/{n++} /^<\/important>/{c++} END{print n, c}' modules/ai/instructions/INSTRUCTIONS.md | tee .sisyphus/evidence/task-6-tags.log
      2. Assert: output is `6 6` — 6 opening tags, 6 closing tags, balanced
    Expected Result: Tag balance is intact
    Failure Indicators: missing `</important>`, extra opening tag, mismatched count
    Evidence: .sisyphus/evidence/task-6-tags.log

  Scenario: Post-switch deployment confirms file is delivered to harness paths (deferred to T7)
    Tool: Bash
    Preconditions: T7 switch ran
    Steps:
      1. Locate where each harness expects this file:
         - claude-code: `~/.claude/CLAUDE.md` (or merged content)
         - codex: `~/.codex/AGENTS.md` (or similar)
         - opencode: `~/.config/opencode/AGENTS.md`
      2. For each path that exists, run: grep -c 'rationalize-and-proceed' <path>
      3. Assert: at least one match across the harness deploy paths
    Expected Result: New rule deployed to at least one harness target (claude / codex / opencode)
    Evidence: .sisyphus/evidence/task-6-deploy.log (captured during T7)
  ```

  **Evidence to Capture**:
  - [ ] `.sisyphus/evidence/task-6-diff.log`
  - [ ] `.sisyphus/evidence/task-6-count.log`
  - [ ] `.sisyphus/evidence/task-6-quote.log`
  - [ ] `.sisyphus/evidence/task-6-key.log`
  - [ ] `.sisyphus/evidence/task-6-tags.log`
  - [ ] `.sisyphus/evidence/task-6-deploy.log` (filled during T7)

  **Commit**: NO (groups with T1-T5 after T7)

- [x] 7. Build, switch, verify, auth bootstrap, and commit

  **What to do**:

  **Phase A — Pre-flight (sanity check)**:
  - From repo root `/Users/matthewthomas/.config/nix`, confirm all Wave 1 edits are present:
    - `grep -q 'agent-slack.url' flake.nix && echo OK`
    - `test -f modules/home-manager/packages/agent-slack/default.nix && echo OK`
    - `grep -q '(pkg "agent-slack")' hosts/work.nix && echo OK`
    - `grep -q '^\s*agent-slack = {' modules/ai/skills/work.nix && echo OK`
    - `! grep -q '^\s*slack = {' modules/ai/mcp/work.nix && echo OK`
    - `grep -q 'rationalize-and-proceed' modules/ai/instructions/INSTRUCTIONS.md && echo OK`
  - If any check fails, halt and report which task was incomplete.
  - Verify Slack Desktop is installed: `test -d /Applications/Slack.app && echo OK` (Metis confirmed it exists; this is belt-and-suspenders).
  - Start Slack Desktop if not running (auth-import needs the running app):
    - `pgrep -x Slack >/dev/null || open -a Slack`
    - Wait ~5s for app to initialize.

  **Phase B — Build verification (must pass before switch)**:
  - `nix flake check 2>&1 | tee .sisyphus/evidence/task-7-flake-check.log` → must exit 0
  - `darwin-rebuild build --flake ~/.config/nix#Castula-KQPN 2>&1 | tee .sisyphus/evidence/task-7-darwin-build.log` → must exit 0

  **Phase C — Apply the generation**:
  - From within devenv shell: `switch` (the devenv script)
  - OR equivalently: `sudo darwin-rebuild switch --flake ~/.config/nix#Castula-KQPN`
  - Capture full output: `2>&1 | tee .sisyphus/evidence/task-7-switch.log`
  - Confirm exit 0 and the message "Done." (or equivalent nix-darwin success line).

  **Phase D — CLI verification**:
  - `which agent-slack` → must print a `/nix/store/*-agent-slack-*/bin/agent-slack` path
  - `agent-slack --version` → prints a version (expected v0.9.3 or newer per upstream)
  - `agent-slack --help | head -40` → prints the command map (auth, message, channel, user, search, workflow, …)
  - Save all CLI outputs to `.sisyphus/evidence/task-7-cli.log`.

  **Phase E — Skill deployment verification**:
  - Locate skill deploy paths (the agent-skills-nix module deploys to claude / codex / agents targets per `modules/ai/skills/default.nix:64-68`):
    - `find ~/.claude/skills ~/.config/codex/skills ~/.agents/skills -maxdepth 3 -name 'SKILL.md' -path '*agent-slack*' 2>/dev/null`
  - Assert: at least one path is returned. Read the first match and capture first 30 lines to `.sisyphus/evidence/task-7-skill.log`.
  - Cross-check: `grep -l 'name: agent-slack' $(find ~/.claude ~/.config/codex ~/.agents -name 'SKILL.md' 2>/dev/null) 2>/dev/null` returns ≥ 1 path.

  **Phase F — INSTRUCTIONS.md deployment verification**:
  - Locate harness instruction deploy paths (this content is shared with claude-code, codex, opencode per `modules/ai/instructions/default.nix`):
    - Likely paths: `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md` (or `~/.config/codex/AGENTS.md`), `~/.config/opencode/AGENTS.md`
    - Run: `for p in ~/.claude/CLAUDE.md ~/.codex/AGENTS.md ~/.config/codex/AGENTS.md ~/.config/opencode/AGENTS.md; do test -f "$p" && echo "$p: $(grep -c 'rationalize-and-proceed' "$p")"; done | tee .sisyphus/evidence/task-7-instructions-deploy.log`
  - Assert: at least one path shows count ≥ 1 (the rule is deployed somewhere downstream).

  **Phase G — MCP removal verification**:
  - `grep -rn 'mcp.slack.com\|1601185624273' modules/ai/ . --exclude-dir=.git --exclude-dir=.sisyphus 2>&1 | tee .sisyphus/evidence/task-7-mcp-gone.log` → zero matches
  - Restart the harness (or open a fresh shell) and confirm `mcp` command (if available) does not list slack: behavior may vary by harness; capture whatever the runtime introspection tool reports.

  **Phase H — Auth bootstrap (interactive)**:
  - If Slack Desktop is running (`pgrep -x Slack`):
    - Run in a tmux pane (via interactive_bash): `agent-slack auth import-desktop 2>&1 | tee .sisyphus/evidence/task-7-auth-import.log`
    - Then: `agent-slack auth whoami 2>&1 | tee .sisyphus/evidence/task-7-auth-whoami.log` — must report the logged-in Slack user (workspace + username/email).
  - If Slack Desktop is NOT running (auto-launch in Phase A failed):
    - Write a deferred-action note to `.sisyphus/evidence/task-7-auth-deferred.log` instructing the user to manually run `agent-slack auth import-desktop` once Slack is running. Do NOT fail the task — surface as a known follow-up.

  **Phase I — Commit (after F1-F4 approval, NOT now)**:
  - This task only stages the verification. The actual commit happens AFTER the Final Verification Wave returns APPROVE from all four reviewers.
  - When committing: use Option A from the Commit Strategy section (single commit, message `feat(ai/work): replace slack mcp with agent-slack CLI + skill, add anti-rationalization rule`).
  - Pre-commit hooks auto-run (treefmt, statix, flake-check, shellcheck).

  **Must NOT do**:
  - Do NOT commit before F1-F4 return APPROVE (commit is gated by the final wave).
  - Do NOT skip `nix flake check` — it catches eval errors before the much-slower darwin-rebuild.
  - Do NOT run `agent-slack auth import-desktop` if Slack Desktop isn't running — it will fail or hang. Surface as deferred instead.
  - Do NOT modify `flake.lock` during this task (it should be locked from T1).
  - Do NOT force-push or roll back the darwin generation without explicit user instruction.
  - Do NOT delete or rotate any agenix secrets (none of them relate to Slack).
  - Do NOT skip the INSTRUCTIONS.md deployment check — this is the only place we confirm the new rule made it to the harness paths.

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: Multi-phase integration: build verification + privileged `switch` + CLI verification + skill verification + INSTRUCTIONS.md verification + interactive auth bootstrap. Combines shell discipline, error-handling around interactive steps (Slack Desktop running or not), and structured evidence capture. Higher effort than a `quick` task.
  - **Skills**: [`nix-darwin`]
    - `nix-darwin`: System rebuild via `darwin-rebuild switch` — the skill describes the build-then-switch workflow, expected output, and rollback behavior. Sole nix-specific skill needed for this task.
  - **Skills Evaluated but Omitted**:
    - `verification-before-completion`: Always implicit for integration tasks; the QA scenarios below enforce it.
    - `playwriter`: agent-slack auth is desktop-app-based (cookies), not web — Playwriter doesn't help here.
    - `chrome-devtools`: Not relevant — no browser involvement.

  **Parallelization**:
  - **Can Run In Parallel**: NO — integration gate
  - **Parallel Group**: Wave 2 (sequential, sole task)
  - **Blocks**: F1, F2, F3, F4 (final verification wave)
  - **Blocked By**: T1, T2, T3, T4, T5, T6 (all Wave 1 must complete first)

  **References**:

  **Pattern References**:
  - `devenv.nix` — defines the `switch` script. Inspect to know the exact invocation.
  - `hosts/work.nix:20` — `hostname = "Castula-KQPN";` — confirms the flake target attribute name for `--flake .#Castula-KQPN`.
  - `lib/mkHost.nix:60` — `sharedModules = applications ++ packages ++ ai;` — confirms that all home-manager modules (including our new agent-slack package and skill source) flow through this single sharedModules attribute. No additional wiring needed.
  - `modules/ai/skills/default.nix:64-68` — `targets = { claude.enable = true; codex.enable = true; agents.enable = true; };` — confirms three deploy paths to check for the new skill.

  **API/Type References**:
  - agent-slack CLI subcommands (from upstream README "Command map"):
    - `auth whoami` — prints current session info
    - `auth test` — sanity check API connectivity
    - `auth import-desktop` — imports Slack Desktop's session cookies
  - `pkgs.stdenv.hostPlatform.system` resolves to `aarch64-darwin` on this host — confirms the per-system package output exists.

  **External References**:
  - agent-slack README (https://github.com/stablyai/agent-slack#getting-started) — auth flow and CLI usage.
  - nix-darwin docs (https://nix-darwin.github.io/nix-darwin/manual/) — `darwin-rebuild` flags.

  **WHY Each Reference Matters**:
  - The `devenv.nix` reference avoids any guesswork about whether to use `switch` (devenv script) vs `darwin-rebuild switch` directly — they should be equivalent.
  - The hostname reference avoids the very common mistake of running `darwin-rebuild switch --flake .` without the `#<hostname>` suffix, which can pick the wrong configuration on a multi-host repo.
  - The `sharedModules` reference is critical: it tells us we don't need to import the new package module anywhere — being on the `packages` list is sufficient.
  - The `targets.{claude,codex,agents}.enable = true` confirms three deploy paths to check, so we don't miss one harness during skill / INSTRUCTIONS verification.

  **Acceptance Criteria**:
  - [ ] `nix flake check` exits 0 (evidence: `.sisyphus/evidence/task-7-flake-check.log`)
  - [ ] `darwin-rebuild build --flake .#Castula-KQPN` exits 0 (evidence: `.sisyphus/evidence/task-7-darwin-build.log`)
  - [ ] `switch` (or `sudo darwin-rebuild switch ...`) exits 0 (evidence: `.sisyphus/evidence/task-7-switch.log`)
  - [ ] `which agent-slack` prints a `/nix/store/.../bin/agent-slack` path (evidence: `.sisyphus/evidence/task-7-cli.log`)
  - [ ] `agent-slack --version` prints a version ≥ v0.9.3 (evidence: same log)
  - [ ] At least one `SKILL.md` for agent-slack is found under `~/.claude/skills/` or `~/.config/codex/skills/` or `~/.agents/skills/` (evidence: `.sisyphus/evidence/task-7-skill.log`)
  - [ ] The new INSTRUCTIONS.md rule (containing `rationalize-and-proceed`) appears in at least one deployed harness instruction file (evidence: `.sisyphus/evidence/task-7-instructions-deploy.log`)
  - [ ] `grep -rn 'mcp.slack.com' modules/ai/` returns zero matches post-switch (evidence: `.sisyphus/evidence/task-7-mcp-gone.log`)
  - [ ] EITHER `agent-slack auth whoami` returns the logged-in user (evidence: `.sisyphus/evidence/task-7-auth-whoami.log`) OR a deferred-action note is written (evidence: `.sisyphus/evidence/task-7-auth-deferred.log`) — never silent failure
  - [ ] All 8 evidence files exist in `.sisyphus/evidence/` (verifiable via `ls -1 .sisyphus/evidence/task-7-*.log | wc -l` ≥ 7 — auth-deferred OR auth-whoami counts as 1 of the slots)

  **QA Scenarios**:

  ```
  Scenario: Build is green (flake check + darwin-rebuild build)
    Tool: Bash
    Preconditions: All Wave 1 tasks complete
    Steps:
      1. Run: nix flake check 2>&1 | tee .sisyphus/evidence/task-7-flake-check.log
      2. Assert: exit code 0; tail of log shows no error markers
      3. Run: darwin-rebuild build --flake ~/.config/nix#Castula-KQPN 2>&1 | tee .sisyphus/evidence/task-7-darwin-build.log
      4. Assert: exit code 0; tail of log shows "Done." or "build done"
    Expected Result: Both commands exit 0 with no error output
    Failure Indicators: missing input error, eval error referencing agent-slack, type error in package module, syntax error in skills/work.nix or mcp/work.nix
    Evidence: .sisyphus/evidence/task-7-flake-check.log, .sisyphus/evidence/task-7-darwin-build.log

  Scenario: Switch applies cleanly
    Tool: interactive_bash (tmux — `switch` requires sudo and may prompt for password)
    Preconditions: build green
    Steps:
      1. tmux new-session: `switch` (or `sudo darwin-rebuild switch --flake ~/.config/nix#Castula-KQPN`)
      2. Provide sudo password if prompted (or run via Touch ID)
      3. Capture full stdout/stderr to .sisyphus/evidence/task-7-switch.log
      4. Assert: exit code 0; final line confirms generation activation
    Expected Result: New generation activated, no rollback triggered
    Failure Indicators: activation failure mid-stream, "error: failed to activate" message
    Evidence: .sisyphus/evidence/task-7-switch.log

  Scenario: agent-slack CLI is on PATH and runnable
    Tool: Bash
    Preconditions: switch complete
    Steps:
      1. Run: which agent-slack 2>&1 | tee -a .sisyphus/evidence/task-7-cli.log
      2. Assert: output starts with `/nix/store/`
      3. Run: agent-slack --version 2>&1 | tee -a .sisyphus/evidence/task-7-cli.log
      4. Assert: output contains a version number (regex: \d+\.\d+\.\d+)
      5. Run: agent-slack --help 2>&1 | head -40 | tee -a .sisyphus/evidence/task-7-cli.log
      6. Assert: output mentions at least `auth`, `message`, `channel`, `user`, `search`
    Expected Result: CLI installed at a nix-store path, prints version + help with the expected command tree
    Failure Indicators: `command not found`, path under `/usr/local` (means npm install leaked through), help output empty
    Evidence: .sisyphus/evidence/task-7-cli.log

  Scenario: Skill is deployed to at least one harness target
    Tool: Bash
    Preconditions: switch complete
    Steps:
      1. Run: find ~/.claude/skills ~/.config/codex/skills ~/.agents/skills -maxdepth 3 -name 'SKILL.md' -path '*agent-slack*' 2>/dev/null | tee .sisyphus/evidence/task-7-skill.log
      2. Assert: at least one path is printed
      3. Run: head -30 "$(head -1 .sisyphus/evidence/task-7-skill.log)" 2>&1 | tee -a .sisyphus/evidence/task-7-skill.log
      4. Assert: frontmatter / SKILL.md content references "Slack" and "CLI"
    Expected Result: Skill installed and readable
    Failure Indicators: zero paths found, file unreadable, content empty
    Evidence: .sisyphus/evidence/task-7-skill.log

  Scenario: New INSTRUCTIONS.md rule is deployed to harness instruction paths
    Tool: Bash
    Preconditions: switch complete
    Steps:
      1. For each candidate path (~/.claude/CLAUDE.md, ~/.codex/AGENTS.md, ~/.config/codex/AGENTS.md, ~/.config/opencode/AGENTS.md): if file exists, grep for "rationalize-and-proceed" and record count
      2. Save aggregate result to .sisyphus/evidence/task-7-instructions-deploy.log
      3. Assert: at least one path has count ≥ 1
    Expected Result: New rule appears in at least one harness instruction file
    Failure Indicators: zero matches across all candidate paths (means INSTRUCTIONS.md change didn't propagate)
    Evidence: .sisyphus/evidence/task-7-instructions-deploy.log

  Scenario: Slack MCP entirely removed from runtime
    Tool: Bash
    Preconditions: switch complete
    Steps:
      1. Run: grep -rn 'mcp.slack.com\|1601185624273.8899143856786' modules/ . --exclude-dir=.git --exclude-dir=.sisyphus 2>&1 | tee .sisyphus/evidence/task-7-mcp-gone.log
      2. Assert: zero matches outside .git and .sisyphus
      3. (If `mcp` runtime introspection is available) confirm slack is not listed among active MCP servers; otherwise note as N/A in the log
    Expected Result: Slack MCP fully purged from source and runtime
    Failure Indicators: any residual reference
    Evidence: .sisyphus/evidence/task-7-mcp-gone.log

  Scenario (happy): Auth bootstrap completes (Slack Desktop running)
    Tool: interactive_bash (tmux)
    Preconditions: switch complete; Slack Desktop running (pgrep -x Slack returns a PID)
    Steps:
      1. tmux: agent-slack auth import-desktop
      2. Capture output to .sisyphus/evidence/task-7-auth-import.log
      3. Assert: completion message (e.g. "Imported session for <user>@<workspace>")
      4. Run: agent-slack auth whoami 2>&1 | tee .sisyphus/evidence/task-7-auth-whoami.log
      5. Assert: output contains a workspace + user identifier
    Expected Result: Authenticated session, whoami reports the right user
    Failure Indicators: import error (cookies missing, app sandboxed), whoami returns "not logged in"
    Evidence: .sisyphus/evidence/task-7-auth-import.log, .sisyphus/evidence/task-7-auth-whoami.log

  Scenario (deferred): Slack Desktop not running — surface action to user, do not fail
    Tool: Bash
    Preconditions: pgrep -x Slack returns no PID
    Steps:
      1. Write to .sisyphus/evidence/task-7-auth-deferred.log:
         "Slack Desktop was not running during T7 execution. Once Slack is launched, run:
           agent-slack auth import-desktop
           agent-slack auth whoami
         to complete the auth bootstrap."
      2. Echo the note to stdout so the orchestrator surfaces it
      3. Assert: file exists, contains the instruction
    Expected Result: Deferred-action note recorded; task continues (does not fail)
    Failure Indicators: silent skip (no note), task marked complete without recording the gap
    Evidence: .sisyphus/evidence/task-7-auth-deferred.log
  ```

  **Evidence to Capture**:
  - [ ] `.sisyphus/evidence/task-7-flake-check.log`
  - [ ] `.sisyphus/evidence/task-7-darwin-build.log`
  - [ ] `.sisyphus/evidence/task-7-switch.log`
  - [ ] `.sisyphus/evidence/task-7-cli.log`
  - [ ] `.sisyphus/evidence/task-7-skill.log`
  - [ ] `.sisyphus/evidence/task-7-instructions-deploy.log`
  - [ ] `.sisyphus/evidence/task-7-mcp-gone.log`
  - [ ] `.sisyphus/evidence/task-7-auth-import.log` AND `.sisyphus/evidence/task-7-auth-whoami.log` _OR_ `.sisyphus/evidence/task-7-auth-deferred.log`

  **Commit**: YES — but only AFTER F1-F4 all return APPROVE
  - Message: `feat(ai/work): replace slack mcp with agent-slack CLI + skill, add anti-rationalization rule`
  - Files: `flake.nix`, `flake.lock`, `modules/home-manager/packages/agent-slack/default.nix` (new), `hosts/work.nix`, `modules/ai/skills/work.nix`, `modules/ai/mcp/work.nix`, `modules/ai/instructions/INSTRUCTIONS.md`
  - Pre-commit hooks (auto via devenv): `treefmt`, `statix`, `flake-check`, `shellcheck`
  - On hook failure: fix issue → create NEW commit (do NOT amend)

---

## Final Verification Wave (MANDATORY — after T7)

> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.

- [x] F1. **Plan Compliance Audit** — `oracle`
      Read this plan end-to-end. For each "Must Have": verify (open files, run commands). For each "Must NOT Have": grep the diff for forbidden patterns — reject with file:line if found. Check evidence files exist in `.sisyphus/evidence/`. Compare actual deliverables against the plan.
      Output: `Must Have [N/N] | Must NOT Have [N/N] | Tasks [N/N] | VERDICT: APPROVE/REJECT`

- [x] F2. **Code Quality Review** — `unspecified-high`
      Run `nix flake check`, `nix fmt -- --ci` (or `treefmt --no-cache --fail-on-change`), and `statix check`. Review the 5 changed files: any commented-out code? Stray TODO comments? Unused imports? Does the new package module match the agenix template exactly? Does the skill-source entry match the existing pattern in `modules/ai/skills/work.nix`?
      Output: `flake check [PASS/FAIL] | fmt [PASS/FAIL] | statix [PASS/FAIL] | Files [N clean/N issues] | VERDICT`

- [x] F3. **Real Manual QA** — `unspecified-high`
      Start from a clean shell. Execute: `which agent-slack`, `agent-slack --version`, `agent-slack --help`, `agent-slack auth whoami` (expect logged-in user post-bootstrap). Inspect skill files: `ls ~/.claude/skills/agent-slack/ && head -n 20 ~/.claude/skills/agent-slack/SKILL.md`. Confirm MCP gone: `grep -rn "mcp.slack.com\|^\s*slack = {" modules/ai/` (expect zero matches). Save outputs to `.sisyphus/evidence/final-qa/`.
      Output: `CLI on PATH [Y/N] | version [v?] | skill files [Y/N] | MCP removed [Y/N] | auth ok [Y/N] | VERDICT`

- [x] F4. **Scope Fidelity Check** — `deep`
      For each of T1-T7: read "What to do", read actual diff (`git diff`). Verify 1:1 — everything in spec was built, nothing beyond spec was built. Check "Must NOT do" compliance per task. Detect cross-task contamination (e.g., T5's MCP removal accidentally touching the exa or claude-mem entries). Confirm `hosts/personal.nix`, `modules/ai/*/personal.nix`, `modules/ai/skills/default.nix`, and `modules/ai/mcp/default.nix` (base, non-work) are UNCHANGED.
      Output: `Tasks [N/N compliant] | Contamination [CLEAN/N issues] | Personal-host CLEAN [Y/N] | Base skills/mcp CLEAN [Y/N] | VERDICT`

---

## Commit Strategy

Single commit (or atomic two-commit split — see below) covers the whole change.

**Option A — single commit (recommended for atomicity)**:

- Message: `feat(ai/work): replace slack mcp with agent-slack CLI + skill, add anti-rationalization rule`
- Files: `flake.nix`, `flake.lock`, `modules/home-manager/packages/agent-slack/default.nix` (new), `hosts/work.nix`, `modules/ai/skills/work.nix`, `modules/ai/mcp/work.nix`, `modules/ai/instructions/INSTRUCTIONS.md`
- Pre-commit: `treefmt`, `statix`, `flake-check` (auto via devenv git hooks)

**Option B — two commits (only if reviewers request the split)**:

1. `feat(ai/work): replace slack mcp with agent-slack CLI + skill` — flake.nix, flake.lock, package module, hosts/work.nix, skills/work.nix, mcp/work.nix
2. `docs(ai/instructions): forbid rationalize-and-proceed pattern under rule ambiguity` — INSTRUCTIONS.md

Default: Option A. Reviewer F2 may request the split during code review.

---

## Success Criteria

### Verification Commands

```bash
# Build green
nix flake check                                       # Expected: exit 0
darwin-rebuild build --flake ~/.config/nix#Castula-KQPN  # Expected: exit 0

# After switch
which agent-slack                                     # Expected: /nix/store/*-agent-slack-*/bin/agent-slack
agent-slack --version                                 # Expected: 0.9.3 or newer
agent-slack auth whoami                               # Expected: logged-in slack user (after auth bootstrap)

# Skill present
ls ~/.claude/skills/agent-slack/ 2>/dev/null || ls -d ~/.config/codex/skills/agent-slack/ 2>/dev/null || ls -d ~/.agents/skills/agent-slack/ 2>/dev/null
# Expected: at least one of the target dirs contains the skill

# MCP removed
grep -rn "mcp.slack.com" modules/ai/                  # Expected: zero matches
grep -n "^\s*slack = {" modules/ai/mcp/work.nix       # Expected: zero matches
```

### Final Checklist

- [ ] All "Must Have" present
- [ ] All "Must NOT Have" absent
- [ ] All file-edit tasks completed
- [ ] `switch` ran cleanly with no warnings
- [ ] agent-slack CLI works
- [ ] Skill is discoverable
- [ ] Slack MCP entirely removed
- [ ] F1-F4 all APPROVED
- [ ] User said "okay"
