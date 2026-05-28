## 2026-05-12

- Kept `agent-slack` in the main flake input set rather than the `flake = false` skill blocks because it is a flake input.
- Followed the repo pattern of pinning nixpkgs for inputs that should share the local nixpkgs evaluation.
- Added the work-only `agent-slack` skill source directly in `modules/ai/skills/work.nix` and left the base/personal skill sets untouched.
