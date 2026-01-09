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
      statusLine = {
        type = "command";
        command = ''
          input=$(cat)
          # Get repo name from git remote or directory name
          repo=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null)
          # Get branch with dirty indicator
          branch=$(git branch --show-current 2>/dev/null)
          if [ -n "$branch" ]; then
            dirty=$(git status --porcelain 2>/dev/null | head -1)
            [ -n "$dirty" ] && branch="$branch*"
          fi
          # Get time remaining from ccusage (extract time pattern like "2h 45m left")
          usage=$(echo "$input" | ${pkgs.bun}/bin/bun x ccusage statusline 2>/dev/null)
          time_left=$(echo "$usage" | ${pkgs.gnugrep}/bin/grep -oE '[0-9]+h [0-9]+m left' || echo "")
          # Build output
          if [ -n "$repo" ] && [ -n "$branch" ]; then
            printf "%s/%s %s" "$repo" "$branch" "$time_left"
          elif [ -n "$branch" ]; then
            printf "%s %s" "$branch" "$time_left"
          else
            printf "%s" "$time_left"
          fi
        '';
      };
    };
  };
}
