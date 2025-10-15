# Hosts-Only Migration TODO

Goal: migrate to a hosts-only structure using options-first modules with two namespaces:
- apps.* for GUI applications
- pkgs.* for CLI/dev tools

Keep global settings.variables.EDITOR and settings.variables.VISUAL centralized and referenced from modules.

Decisions
- Hosts only: use hosts/work and hosts/personal; no roles.
- Namespaces: apps.* (GUI), pkgs.* (CLI/dev).
- Keep global settings.variables for EDITOR/VISUAL.
- Never build/switch in this plan; use show/eval/check only.

Phase 1 — Scaffolding
- [x] Create hosts/work/default.nix that composes:
  - ../../system/core
  - ../../system/darwin.nix
  - inputs.home-manager.darwinModules.home-manager
  - ../../modules/applications (aggregator)
  - ../../modules/packages (aggregator)
  - Inline host toggles: networking.hostName, apps.*, pkgs.* (incl. pkgs.git identity)
- [x] Create hosts/personal/default.nix mirroring the structure for the personal machine
- [x] Add modules/applications/default.nix aggregator importing all application modules
- [x] Add modules/packages/default.nix aggregator importing all package modules
- [x] Centralize HM stateVersion in a common/system module (e.g., system/core)
  - home-manager.users.${config.user}.home.stateVersion = "25.05"
- [x] Centralize unfree policy once (common/system):
  - nixpkgs.config.allowUnfree = true
  - nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfreePackages

Validation (no builds)
- [x] nix flake show (ensure new targets appear when wired)
- [x] nix eval .#darwinConfigurations.work.config.networking.hostName
- [x] nix flake check (sanity; do not switch/build)

Phase 2 — Pilot Optionization
- [x] Convert modules/applications/zed.nix to options-first under apps.zed.*
  - options: apps.zed.enable, apps.zed.settings (attrs)
  - config: mkIf (cfg.enable && pkgs.stdenv.isDarwin) { programs.zed-editor.* }
- [x] Convert modules/packages/git.nix to options-first under pkgs.git.*
  - options: pkgs.git.enable, pkgs.git.userName, pkgs.git.userEmail
  - config: mkIf cfg.enable { programs.git.*; use settings.variables.VISUAL for core.editor }
- [x] Import both via aggregators; set toggles in hosts/*

Validation (no builds)
- [x] nix eval .#darwinConfigurations.work.config.home-manager.users.mattietea.apps.zed.enable
- [x] nix eval .#darwinConfigurations.work.config.home-manager.users.mattietea.programs.zed-editor.enable
- [x] nix eval .#darwinConfigurations.work.config.home-manager.users.mattietea.programs.git.userEmail
- [x] nix flake check

Phase 3 — Flake Wiring (Non-Breaking)
- [x] Add darwinConfigurations.work = import ./hosts/work { inherit inputs settings; }
- [x] Add darwinConfigurations.personal = import ./hosts/personal { inherit inputs settings; }
- [x] Keep existing Matts-* outputs temporarily for continuity

Validation (no builds)
- [x] nix flake show (verify work and personal present)
- [x] nix eval .#darwinConfigurations.personal.config.apps.zed.enable

Phase 4 — Convert Remaining Modules to Options-First
- [x] Apps (apps.*):
  - [x] modules/applications/discord.nix
  - [x] modules/applications/notion.nix
  - [x] modules/applications/raycast.nix
  - [x] modules/applications/spotify.nix
- [x] Pkgs (pkgs.*):
  - [x] modules/packages/bat.nix
  - [x] modules/packages/bun.nix
  - [x] modules/packages/delta.nix
  - [x] modules/packages/dotenv.nix
  - [x] modules/packages/eza.nix
  - [x] modules/packages/fonts.nix
  - [x] modules/packages/fzf.nix
  - [x] modules/packages/gh.nix
  - [x] modules/packages/git-absorb.nix
  - [x] modules/packages/git-machete.nix
  - [x] modules/packages/graphite.nix
  - [x] modules/packages/lazygit.nix
  - [x] modules/packages/node.nix
  - [x] modules/packages/opencode.nix
  - [x] modules/packages/pnpm.nix
  - [x] modules/packages/pure.nix
  - [x] modules/packages/rename-utils.nix
  - [x] modules/packages/shopify.nix
  - [x] modules/packages/starship.nix
  - [x] modules/packages/television.nix
  - [x] modules/packages/tldr.nix
  - [x] modules/packages/zsh.nix

Validation loop (no builds)
- [x] After each conversion, toggle in one host and run:
  - nix eval .#darwinConfigurations.work.config.programs.<tool>.enable (or app-specific attr)
  - nix flake check

Phase 5 — Unfree + Common Polish
- [x] In each app requiring unfree, append its name to unfreePackages inside mkIf
- [x] Confirm allowUnfreePredicate is defined once in common/system code
- [x] Keep mac-app-util wiring (if in shared modules) unchanged

Validation (no builds)
- [x] nix eval .#darwinConfigurations.work.config.nixpkgs.config.allowUnfreePredicate (should return a lambda)
- [x] nix flake check

Phase 6 — Flip Over & Cleanup
- [x] Replace old Matts-* outputs (or alias them) with work and personal
- [x] Remove legacy builder (utils/build-darwin.nix) if superseded by host files
- [x] Align any mismatched paths in flake.nix (e.g., modules/utils/build-darwin.nix vs utils/build-darwin.nix)

Validation (no builds)
- [x] nix flake show (only desired targets remain)
- [x] nix flake check

Reference Snippets
- Host file (work):
  - inputs.darwin.lib.darwinSystem { system = "aarch64-darwin"; specialArgs = { inherit inputs settings; }; modules = [ ../../system/core ../../system/darwin.nix inputs.home-manager.darwinModules.home-manager ../../modules/applications ../../modules/packages { networking.hostName = "Matts-Work-MacBook-Pro"; apps = { spotify.enable = true; raycast.enable = true; zed.enable = true; discord.enable = false; }; pkgs = { git = { enable = true; userName = "Mattie Tea"; userEmail = "work@example.com"; }; zsh.enable = true; delta.enable = true; lazygit.enable = true; gh.enable = true; fonts.enable = true; fzf.enable = true; eza.enable = true; tldr.enable = true; pure.enable = true; graphite.enable = true; rename-utils.enable = true; git-absorb.enable = true; git-machete.enable = true; opencode.enable = true; }; } ]; }
- App module (Zed):
  - options.apps.zed.enable = mkEnableOption "Zed editor";
  - options.apps.zed.settings = mkOption { type = types.attrs; default = {}; };
  - config = mkIf (cfg.enable && pkgs.stdenv.isDarwin) { programs.zed-editor.enable = true; programs.zed-editor.userSettings = defaults // cfg.settings; };
- Pkg module (Git):
  - options.pkgs.git = { enable = mkEnableOption "Git"; userName = mkOption { type = types.str; default = ""; }; userEmail = mkOption { type = types.str; default = ""; }; };
  - config = mkIf cfg.enable { programs.git.enable = true; programs.git.userName = cfg.userName; programs.git.userEmail = cfg.userEmail; programs.git.extraConfig.core.editor = settings.variables.VISUAL; };
