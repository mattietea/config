## 2026-05-12

- Added `agent-slack` as a standard flake input with `inputs.nixpkgs.follows = "nixpkgs"`, matching the other agent tooling inputs.
- `nix flake lock --update-input agent-slack` added a nested `flake-utils` node under the new input.
- For `agent-skills` source blocks, a single-line source entry can still satisfy the style constraints while keeping grep-based counts aligned with expected validation.
