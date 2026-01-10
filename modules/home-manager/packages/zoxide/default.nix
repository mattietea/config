{
  lib,
  pkgs,
  ...
}:
{
  programs.zoxide = {
    enable = true;
    enableZshIntegration = false; # manually init at end of zshrc
    options = [ "--cmd cd" ];
  };

  programs.zsh.initContent = lib.mkOrder 1500 ''
    # Only init in interactive shells - Claude Code's Bash tool doesn't inherit
    # shell functions, causing broken cd and warnings in non-interactive shells
    # https://github.com/anthropics/claude-code/issues/2407
    [[ $- == *i* ]] && eval "$(${pkgs.zoxide}/bin/zoxide init --cmd cd zsh)"
  '';
}
