{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  codexPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
  claudeMemManifest = builtins.fromJSON (
    builtins.readFile "${inputs.claude-mem}/.codex-plugin/plugin.json"
  );
in
{
  programs.codex = {
    enable = true;
    # Use the pre-built codex from llm-agents.nix (numtide) so we hit
    # cache.numtide.com instead of building from source against nixpkgs.
    # Mirrors how opencode is wired in ../opencode/default.nix.
    package = codexPackage;
    enableMcpIntegration = true;
    settings = {
      approval_policy = "never";
      model = "gpt-5.5";
      model_reasoning_effort = "high";
      sandbox_mode = "danger-full-access";
      features.hooks = true;
      marketplaces.claude-mem-local = {
        source_type = "local";
        source = "${config.home.homeDirectory}/.claude/plugins/marketplaces/thedotmack";
      };
      plugins."claude-mem@claude-mem-local".enabled = true;
      hooks.state = {
        "${config.home.homeDirectory}/.codex/hooks.json:pre_tool_use:0:0".trusted_hash =
          "sha256:c9621198c46f5bc6032a626e91e1b89c84d3467b003c39db33ffd9ce764c7db0";
        "${config.home.homeDirectory}/.codex/hooks.json:permission_request:0:0".trusted_hash =
          "sha256:5ed3479622a78f4a7d42df5e73499499e3e427e8033abda59d7354f7561f4248";
        "${config.home.homeDirectory}/.codex/hooks.json:post_tool_use:0:0".trusted_hash =
          "sha256:83441ac77a145163f300d664df3b9f9a5039faf2e386e8f176752b11b2feab08";
        "${config.home.homeDirectory}/.codex/hooks.json:session_start:0:0".trusted_hash =
          "sha256:293270706daf9f175638efba6f4cd3e40c15b8c794ee99387b1419bd5485267f";
        "${config.home.homeDirectory}/.codex/hooks.json:user_prompt_submit:0:0".trusted_hash =
          "sha256:f6fa08a1ff537710d1cc37f2e90cd703542586423b88c8477cf548b786360ee1";
        "${config.home.homeDirectory}/.codex/hooks.json:stop:0:0".trusted_hash =
          "sha256:0a4be757d49d460b50264992495c1b2ddb1b4e8c0928cd47e3ce31543eff537c";
        "claude-mem@claude-mem-local:hooks/codex-hooks.json:pre_tool_use:0:0".trusted_hash =
          "sha256:be527484c3c5fb02c5bc846149f8d5e164918d2d5ea5d2c961a09037db8c4905";
        "claude-mem@claude-mem-local:hooks/codex-hooks.json:post_tool_use:0:0".trusted_hash =
          "sha256:a49c41be9e7dbc00e03703265adefdca46e12b77d722ca8b47fa0094db82f93b";
        "claude-mem@claude-mem-local:hooks/codex-hooks.json:session_start:0:0".trusted_hash =
          "sha256:84922f02a2c8ac9df62faaa0b63c38778360cd9900554bdec989108f796841ab";
        "claude-mem@claude-mem-local:hooks/codex-hooks.json:session_start:0:1".trusted_hash =
          "sha256:73009d71492f3db420bb856eb972da392e678eadcbc7e1e125e7430a67d49f4b";
        "claude-mem@claude-mem-local:hooks/codex-hooks.json:session_start:0:2".trusted_hash =
          "sha256:19949ab8aadd05443e67e1b66298d8e303b7c5a7150aae85114a04563e35d9c0";
        "claude-mem@claude-mem-local:hooks/codex-hooks.json:user_prompt_submit:0:0".trusted_hash =
          "sha256:c9ed4da2921325c632de9c9b4754dfd6edb753d8548f946a6073c4876507d44a";
        "claude-mem@claude-mem-local:hooks/codex-hooks.json:stop:0:0".trusted_hash =
          "sha256:1e99bde05721215c13722e100fd2ed6657dacffab6e1c5dcb9be47a56bf6f6d5";
      };
      projects."${config.home.homeDirectory}/.config/nix".trust_level = "trusted";
    };
  };

  home = {
    file = {
      ".local/share/claude-mem/codex-hook-filter.js".text = ''
        let input = "";

        process.stdin.setEncoding("utf8");
        process.stdin.on("data", chunk => {
          input += chunk;
        });
        process.stdin.on("end", () => {
          const trimmed = input.trim();
          if (!trimmed) {
            process.exit(0);
          }

          try {
            const output = JSON.parse(trimmed);
            if (output && typeof output === "object" && !Array.isArray(output)) {
              delete output.suppressOutput;
              delete output.status;
              delete output.message;
              process.stdout.write(JSON.stringify(output));
              process.exit(0);
            }
          } catch {
            // Preserve non-JSON output so real hook failures still surface.
          }

          process.stdout.write(input);
        });
      '';

      ".local/share/claude-mem/wrap-codex-hooks.js".text = ''
        const fs = require("fs");

        const [hooksFile, filter, node] = process.argv.slice(2);
        const marker = "codex-hook-filter.js";

        function shellQuote(value) {
          const sq = String.fromCharCode(39);
          return sq + String(value).replace(new RegExp(sq, "g"), sq + "\"" + sq + "\"" + sq) + sq;
        }

        function wrap(command) {
          if (command.includes(marker)) {
            return command;
          }

          return [
            "_CLAUDE_MEM_CODEX_HOOK_OUT=$(mktemp)",
            "( " + command + " ) >\"$_CLAUDE_MEM_CODEX_HOOK_OUT\"",
            "_CLAUDE_MEM_CODEX_HOOK_STATUS=$?",
            shellQuote(node) + " " + shellQuote(filter) + " <\"$_CLAUDE_MEM_CODEX_HOOK_OUT\"",
            "rm -f \"$_CLAUDE_MEM_CODEX_HOOK_OUT\"",
            "exit \"$_CLAUDE_MEM_CODEX_HOOK_STATUS\""
          ].join("; ");
        }

        function visit(value) {
          if (Array.isArray(value)) {
            value.forEach(visit);
            return;
          }

          if (!value || typeof value !== "object") {
            return;
          }

          if (value.type === "command" && typeof value.command === "string") {
            value.command = wrap(value.command);
          }

          Object.values(value).forEach(visit);
        }

        const hooks = JSON.parse(fs.readFileSync(hooksFile, "utf8"));
        visit(hooks);
        fs.writeFileSync(hooksFile, JSON.stringify(hooks, null, 2) + "\n");
      '';
    };

    activation.installClaudeMemRuntime = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      version="${claudeMemManifest.version}"
      source="${inputs.claude-mem}"
      marketplace="$HOME/.claude/plugins/marketplaces/thedotmack"
      cache="$HOME/.claude/plugins/cache/thedotmack/claude-mem/$version"
      source_marker=".nix-source-path"

      copy_marketplace=0
      if [ ! -f "$marketplace/$source_marker" ] || [ "$(cat "$marketplace/$source_marker")" != "$source" ]; then
        copy_marketplace=1
      fi

      if [ "$copy_marketplace" -eq 1 ]; then
        mkdir -p "$marketplace"
        for entry in .agents .codex-plugin plugin package.json package-lock.json openclaw dist LICENSE README.md CHANGELOG.md; do
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

      wrap_codex_hook_commands() {
        hooks_file="$marketplace/plugin/hooks/codex-hooks.json"
        filter="$HOME/.local/share/claude-mem/codex-hook-filter.js"
        wrapper="$HOME/.local/share/claude-mem/wrap-codex-hooks.js"
        if [ ! -f "$hooks_file" ]; then
          return
        fi

        ${pkgs.nodejs}/bin/node "$wrapper" "$hooks_file" "$filter" "${pkgs.nodejs}/bin/node"
      }

      wrap_codex_hook_commands

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

      if [ "$copy_cache" -eq 1 ] || [ ! -d "$cache/node_modules" ]; then
        ${pkgs.bun}/bin/bun install --cwd "$cache"
      fi
      write_marker "$cache"

      if [ "$copy_marketplace" -eq 1 ] || [ ! -d "$marketplace/node_modules" ]; then
        ${pkgs.nodejs}/bin/npm install --omit=dev --legacy-peer-deps --prefix "$marketplace"
      fi
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
  };
}
