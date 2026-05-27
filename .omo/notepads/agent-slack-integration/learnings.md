## Task 7 — Notepad: Learnings

### Outcome

Commit: 81bf70d — 7 files changed, 103 insertions(+), 10 deletions(-)
All pre-commit hooks (deadnix, flake-check, statix, treefmt) passed.

### Patterns that worked

- `git add -N` (intent-to-add) on the new agent-slack package dir before `nix flake check` — flakes ignore untracked files, but -N makes them visible without staging content.
- Touch ID sudo via /etc/pam.d/sudo_local — `devenv shell -- switch` worked seamlessly.
- Auth import-desktop reads Slack Desktop's leveldb + cookies; imported 3 workspaces in one call.

### Notes / Caveats

- `which agent-slack` returns `/opt/homebrew/bin/agent-slack` (0.9.3), not the nix store path. Reason: user has a global npm install of agent-slack via homebrew node that shadows the nix profile in PATH.
- Nix-installed binary IS present and functional at `/etc/profiles/per-user/matthewthomas/bin/agent-slack` -> `/nix/store/vgsirmfvzq6gawjjsmvgd2qi5bkwkp2g-agent-slack-0.5.2/bin/agent-slack` (version 0.5.2).
- agent-slack 0.9.3 is newer than the 0.5.2 we pinned in nix; consider `nix flake update` of the agent-slack input in a future task.
- Skill find pattern `-name SKILL.md -path '*agent-slack*'` failed on symlinks; `ls ~/.agents/skills/` showed the agent-slack -> /nix/store/... symlink directly.
