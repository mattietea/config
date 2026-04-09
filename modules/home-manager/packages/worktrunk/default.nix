{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.worktrunk ];

  programs.zsh.initContent = ''
    eval "$(${pkgs.worktrunk}/bin/wt config shell init zsh)"

    functions[_wt_shell]=$functions[wt]
    wt() {
      if [ "$1" = "prune" ]; then
        shift
        local branches
        branches=$(command ${pkgs.worktrunk}/bin/wt list --format json | ${pkgs.jq}/bin/jq -r '.[] | select(.is_main == false and .is_current == false) | .branch' | ${pkgs.fzf}/bin/fzf --multi --header "Select worktrees to remove (TAB to multi-select)")
        [ -z "$branches" ] && return
        echo "$branches" | xargs command ${pkgs.worktrunk}/bin/wt remove -y "$@"
      else
        _wt_shell "$@"
      fi
    }
  '';
}
