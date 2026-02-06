{
  pkgs,
  ...
}:
let
  # Delta can't auto-detect dark/light inside lazygit's TUI (OSC query gets swallowed).
  # This wrapper checks macOS appearance directly.
  delta-lazygit = pkgs.writeShellScript "delta-lazygit" ''
    if [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" = "Dark" ]; then
      exec ${pkgs.delta}/bin/delta --dark --paging=never "$@"
    else
      exec ${pkgs.delta}/bin/delta --light --paging=never "$@"
    fi
  '';
in
{
  programs.lazygit.enable = true;

  programs.lazygit.settings = {
    git = {
      autoFetch = false;
      fetchAll = false;
      pagers = [ { pager = "${delta-lazygit}"; } ];
    };
    gui = {
      nerdFontsVersion = "3";
      showCommandLog = false;
      border = "single";
      skipStashWarning = true;
      filterMode = "fuzzy";
      commitHashLength = 4;
    };
  };
}
