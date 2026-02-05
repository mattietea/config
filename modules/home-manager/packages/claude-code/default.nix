{
  pkgs,
  ...
}:
{
  # Required for macOS desktop notifications and auto-memory plugin
  home.packages = [
    pkgs.terminal-notifier
    pkgs.python3
  ];

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      model = "opus";
      defaultMode = "plan";
      permissions = {
        allow = [
          "Read"
          "Edit"
          "Write"
          "Glob"
          "Grep"
          "LS"
          "Task"
          "WebFetch"
          "WebSearch"

          "Bash(git:*)"
          "Bash(ls:*)"
          "Bash(cat:*)"
          "Bash(pwd:*)"
          "Bash(cd:*)"
          "Bash(find:*)"
          "Bash(grep:*)"
          "Bash(rg:*)"
          "Bash(head:*)"
          "Bash(tail:*)"
          "Bash(wc:*)"
          "Bash(echo:*)"
          "Bash(which:*)"
          "Bash(diff:*)"

          "Bash(npm:*)"
          "Bash(npx:*)"
          "Bash(yarn:*)"
          "Bash(pnpm:*)"
          "Bash(bun:*)"
          "Bash(node:*)"
          "Bash(tsc:*)"
          "Bash(eslint:*)"
          "Bash(prettier:*)"

          "Bash(python:*)"
          "Bash(pip:*)"
          "Bash(uv:*)"

          "Bash(cargo:*)"
          "Bash(go:*)"

          "Bash(make:*)"
          "Bash(jq:*)"
          "Bash(gh:*)"
        ];
        deny = [
          "Read(.env)"
          "Read(.env.*)"
          "Read(**/.env)"
          "Read(**/.env.*)"
          "Read(**/secrets/**)"
          "Read(**/*secret*)"
          "Read(**/*credential*)"
          "Read(~/.ssh/**)"
          "Read(~/.aws/**)"

          "Bash(su:*)"
          "Bash(chmod 777:*)"
          "Bash(shutdown:*)"
          "Bash(reboot:*)"
        ];
      };
      attribution = {
        commit = "";
        pr = "";
      };
      enabledPlugins = {
        "oh-my-claudecode@omc" = true;
        "auto-memory@severity1-marketplace" = true;
        "code-simplifier@claude-plugins-official" = true;
        "claude-notifications-go@claude-notifications-go" = true;
      };
      extraKnownMarketplaces = {
        omc = {
          source = {
            source = "github";
            repo = "Yeachan-Heo/oh-my-claudecode";
          };
        };
        severity1-marketplace = {
          source = {
            source = "github";
            repo = "severity1/severity1-marketplace";
          };
        };
        claude-plugins-official = {
          source = {
            source = "github";
            repo = "anthropics/claude-plugins-official";
          };
        };
        claude-notifications-go = {
          source = {
            source = "github";
            repo = "777genius/claude-notifications-go";
          };
        };
      };
      statusLine = {
        type = "command";
        command = "node ~/.claude/hud/omc-hud.mjs";
      };
    };
  };
}
