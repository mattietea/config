{
  config,
  pkgs,
  lib,
  sources,
  ...
}:
let
  inherit (sources.claude-mem) version;

  # Build-time wrapped marketplace tree.
  #
  # claude-mem's published npm tarball is fully self-contained: the CLI
  # (dist/npx-cli/index.js) and every plugin script (plugin/scripts/*.cjs) are
  # pre-bundled with their dependencies inlined, so there are no node_modules to
  # install — plain tarball extraction is the complete, supported install.
  #
  # sources.claude-mem (nvfetcher) tracks npm's dist-tags `latest` and fetches
  # that exact tarball by its own integrity hash — no FOD output hashes to
  # maintain, no activation-time network; `update` refreshes the pin.
  #
  # Pure derivation: unpacks the tarball, then runs wrap-codex-hooks.js over
  # plugin/hooks/codex-hooks.json (pure JSON in / pure JSON out) to strip the
  # Claude-Code-style output fields ({suppressOutput,status,message}) that Codex
  # rejects. The result is a Nix-store path with the full claude-mem marketplace.
  wrappedMarketplace =
    pkgs.runCommand "claude-mem-codex-marketplace-${version}"
      {
        nativeBuildInputs = [ pkgs.nodejs ];
        src = sources.claude-mem.src;
      }
      ''
        mkdir -p $out
        tar xzf $src --strip-components=1 -C $out
        chmod -R u+w $out
        ${pkgs.nodejs}/bin/node ${./wrap-codex-hooks.js} \
          "$out/plugin/hooks/codex-hooks.json" \
          ${./codex-hook-filter.js} \
          ${pkgs.nodejs}/bin/node
      '';
in
{
  # Codex plugin/marketplace discovery — moved here from the codex harness
  # module so the harness can stay claude-mem-agnostic.
  programs.codex.settings = {
    marketplaces.claude-mem-local = {
      source_type = "local";
      source = "${config.home.homeDirectory}/.claude/plugins/marketplaces/thedotmack";
    };
    plugins."claude-mem@claude-mem-local".enabled = true;
  };

  # Point claude-mem hook commands at the build-time-wrapped Nix-store path.
  #
  # The shipped hook commands first check ${CLAUDE_PLUGIN_ROOT:-${PLUGIN_ROOT:-}}
  # before falling back to globbing ~/.claude/plugins/cache/.../[0-9]*/.
  # Setting this makes hook resolution deterministic across claude-mem version
  # bumps and independent of the activation-time copy below — so even if the
  # home-dir marketplace is stale, hooks resolve to the current Nix store.
  home.sessionVariables.CLAUDE_PLUGIN_ROOT = "${wrappedMarketplace}";

  # Mirror the build-time wrapped marketplace into ~/.claude/plugins/marketplaces/
  # because:
  #   - Claude Code's plugin loader scans this path
  #   - the runtime expects a writable copy (state, markers)
  #   - modules/ai/mcp/default.nix references the mcp-server.cjs path here
  #
  # The .nix-source-path marker lets activation skip the copy when the source
  # derivation hasn't changed since the previous generation.
  #
  # node_modules for both trees are baked into wrappedMarketplace at build
  # time (see above) — activation only copies, it never touches the network.
  home.activation.installClaudeMemRuntime = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    version="${version}"
    source="${wrappedMarketplace}"
    marketplace="$HOME/.claude/plugins/marketplaces/thedotmack"
    cache="$HOME/.claude/plugins/cache/thedotmack/claude-mem/$version"
    source_marker=".nix-source-path"

    copy_marketplace=0
    if [ ! -f "$marketplace/$source_marker" ] || [ "$(cat "$marketplace/$source_marker")" != "$source" ]; then
      copy_marketplace=1
    fi

    if [ "$copy_marketplace" -eq 1 ]; then
      mkdir -p "$marketplace"
      for entry in .agents .codex-plugin plugin package.json openclaw dist LICENSE README.md; do
        if [ -e "$source/$entry" ]; then
          rm -rf "$marketplace/$entry"
          cp -R "$source/$entry" "$marketplace/$entry"
        fi
      done
      chmod -R u+w "$marketplace"
      printf '%s' "$source" > "$marketplace/$source_marker"
    fi

    copy_cache=0
    if [ ! -f "$cache/$source_marker" ] || [ "$(cat "$cache/$source_marker")" != "$source" ]; then
      copy_cache=1
    fi

    if [ "$copy_marketplace" -eq 1 ] || [ "$copy_cache" -eq 1 ]; then
      old_worker="$marketplace/plugin/scripts/worker-service.cjs"
      if [ -f "$old_worker" ]; then
        ${pkgs.bun}/bin/bun "$old_worker" stop >/dev/null 2>&1 || true
      fi
    fi

    if [ "$copy_cache" -eq 1 ]; then
      rm -rf "$cache"
      mkdir -p "$(dirname "$cache")"
      cp -R "$source/plugin" "$cache"
      chmod -R u+w "$cache"
      printf '%s' "$source" > "$cache/$source_marker"
    fi

    write_marker() {
      marker_dir="$1"
      ${pkgs.nodejs}/bin/node -e '
        const fs = require("fs");
        const marker = {
          version: process.env.CLAUDE_MEM_VERSION,
          bun: process.env.CLAUDE_MEM_BUN_VERSION,
          uv: process.env.CLAUDE_MEM_UV_VERSION,
          installedAt: new Date().toISOString()
        };
        fs.writeFileSync(process.argv[1] + "/.install-version", JSON.stringify(marker));
      ' "$marker_dir"
    }

    export CLAUDE_MEM_VERSION="$version"
    export CLAUDE_MEM_BUN_VERSION="$(${pkgs.bun}/bin/bun --version)"
    uv_version="$(${pkgs.uv}/bin/uv --version)"
    export CLAUDE_MEM_UV_VERSION="''${uv_version#uv }"

    write_marker "$cache"
    write_marker "$marketplace/plugin"

    export CLAUDE_MEM_MARKETPLACE="$marketplace"
    export CLAUDE_MEM_CACHE="$cache"
    ${pkgs.nodejs}/bin/node -e '
      const fs = require("fs");
      const path = require("path");

      function readJson(file, fallback) {
        try {
          return JSON.parse(fs.readFileSync(file, "utf8"));
        } catch {
          return fallback;
        }
      }

      function writeJson(file, value) {
        fs.mkdirSync(path.dirname(file), { recursive: true });
        fs.writeFileSync(file, JSON.stringify(value, null, 2) + "\n");
      }

      const home = process.env.HOME;
      const pluginsDir = path.join(home, ".claude", "plugins");
      const marketplace = process.env.CLAUDE_MEM_MARKETPLACE;
      const cache = process.env.CLAUDE_MEM_CACHE;
      const version = process.env.CLAUDE_MEM_VERSION;
      const now = new Date().toISOString();

      const knownPath = path.join(pluginsDir, "known_marketplaces.json");
      const known = readJson(knownPath, {});
      known.thedotmack = {
        source: { source: "github", repo: "thedotmack/claude-mem" },
        installLocation: marketplace,
        lastUpdated: now,
        autoUpdate: true
      };
      writeJson(knownPath, known);

      const installedPath = path.join(pluginsDir, "installed_plugins.json");
      const installed = readJson(installedPath, {});
      installed.version ??= 2;
      installed.plugins ??= {};
      installed.plugins["claude-mem@thedotmack"] = [{
        scope: "user",
        installPath: cache,
        version,
        installedAt: now,
        lastUpdated: now
      }];
      writeJson(installedPath, installed);
    '
  '';
}
