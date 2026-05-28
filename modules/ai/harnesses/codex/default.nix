{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  programs.codex = {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
    enableMcpIntegration = true;
    settings = {
      approval_policy = "never";
      model = "gpt-5.5";
      model_reasoning_effort = "high";
      sandbox_mode = "danger-full-access";
      features.hooks = true;
      projects."${config.home.homeDirectory}/.config/nix".trust_level = "trusted";
    };
  };

  # Bypass Codex's hook-trust verification on every interactive `codex`
  # invocation. Mirrors the `claude` alias pattern. Non-interactive codex
  # invocations (e.g. `codex exec` from a script) won't get the flag and may
  # hit trust prompts. Plugin/marketplace wiring for claude-mem lives in
  # ../../integrations/claude-mem.
  programs.zsh.shellAliases.codex = "codex --dangerously-bypass-hook-trust";

  # Make ~/.codex/config.toml writable so Codex can persist runtime-managed
  # state (hook trust grants, hook enable/disable flips from the TUI).
  #
  # Without this, ~/.codex/config.toml is a Nix-store symlink (read-only) and
  # any TUI action that writes to config produces "config/batchWrite failed
  # while updating hook trust/enablement in TUI" startup spam, AND trust
  # grants never persist — so the hook-review prompt reappears every session
  # for hooks shipped by plugins (e.g. claude-mem).
  #
  # Mechanism — three coordinated pieces:
  #   1. `force = true` lets HM overwrite our mutable file with its symlink
  #      every switch (otherwise HM aborts with "existing file in the way").
  #   2. `codexConfigSnapshot` runs BEFORE HM's write phase, capturing
  #      [hooks.state] from the prior mutable file so Codex's accumulated
  #      trust grants survive the switch.
  #   3. `codexConfigMakeMutable` runs AFTER HM's symlink is in place,
  #      reading the Nix-managed TOML through the symlink, then replacing
  #      the symlink with a regular file that combines Nix-managed content
  #      with the preserved [hooks.state] section.
  #
  # Codex owns [hooks.state]; Nix owns everything else. They coexist via
  # an explicit section split — the awk extractor only preserves the
  # [hooks.state] block (lines from the [hooks.state] header to the next
  # [section] header). Any other Codex-side mutations are NOT preserved.
  home = {
    file.".codex/config.toml".force = true;

    activation = {
      codexConfigSnapshot = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
        cfg="$HOME/.codex/config.toml"
        snapshot="$HOME/.codex/.config.toml.nix-snapshot"
        if [ -f "$cfg" ] && [ ! -L "$cfg" ]; then
          cp "$cfg" "$snapshot"
        fi
      '';

      codexConfigMakeMutable = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        cfg="$HOME/.codex/config.toml"
        snapshot="$HOME/.codex/.config.toml.nix-snapshot"

        if [ ! -L "$cfg" ]; then
          # Either first install with no file at all, or already a mutable file.
          # Ensure writable and clean up snapshot.
          if [ -f "$cfg" ]; then
            chmod u+w "$cfg" 2>/dev/null || true
          fi
          rm -f "$snapshot"
          exit 0
        fi

        # Read the Nix-managed content via the symlink.
        nix_managed="$(cat "$cfg")"

        # Extract [hooks.state] from the snapshot (Codex's accumulated trust state).
        preserved=""
        if [ -f "$snapshot" ]; then
          preserved="$(${pkgs.gawk}/bin/awk '
            /^\[hooks\.state\]/ { in_hs = 1; print; next }
            in_hs && /^\[/      { exit }
            in_hs               { print }
          ' "$snapshot")"
        fi

        # Replace the symlink with a mutable file.
        rm "$cfg"
        {
          printf '%s\n' "$nix_managed"
          if [ -n "$preserved" ]; then
            printf '\n%s\n' "$preserved"
          fi
        } > "$cfg"
        chmod u+w "$cfg"
        rm -f "$snapshot"
      '';
    };
  };
}
