{ pkgs, ... }:
{

  programs.claude-code = {
    enable = true;
    mcpServers = {
      context7 = {
        type = "http";
        url = "https://mcp.context7.com/mcp";
      };
    };
    settings = {
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
      statusLine = {
        type = "command";
        command = ''
          input=$(cat)

          # Git info: repo/branch with dirty indicator
          if toplevel=$(git rev-parse --show-toplevel 2>/dev/null); then
            repo=$(basename "$toplevel")
            branch=$(git branch --show-current 2>/dev/null)
            [ -n "$(git status --porcelain 2>/dev/null)" ] && branch="$branch*"
            git_info="$repo/$branch"
          fi

          # Usage time remaining
          time_left=$(echo "$input" | ${pkgs.bun}/bin/bun x ccusage statusline 2>/dev/null | ${pkgs.gnugrep}/bin/grep -oE '[0-9]+h [0-9]+m left') || true

          printf "%s" "''${git_info}''${git_info:+ }$time_left"
        '';
      };
    };
  };
}
