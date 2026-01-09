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
