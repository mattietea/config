{
  pkgs,
  ...
}:
{
  programs = {
    ghostty.settings.command = "${pkgs.tmux}/bin/tmux new-session -A -s main";

    zsh.initContent = ''
      if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
        source "${pkgs.ghostty-bin}/share/ghostty/shell-integration/zsh/ghostty-integration"
      fi
    '';

    tmux = {
      enable = true;
      terminal = "xterm-ghostty";
      historyLimit = 50000;
      mouse = true;
      keyMode = "vi";
      escapeTime = 0;
      baseIndex = 1;
      clock24 = true;

      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        {
          plugin = resurrect;
          extraConfig = "set -g @resurrect-strategy-nvim 'session'";
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '10'
          '';
        }
      ];

      extraConfig = ''
        # Copy tmux selections into the macOS clipboard.
        bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "/usr/bin/pbcopy"

        # Paste directly from the macOS clipboard.
        bind-key ] run-shell "/usr/bin/pbpaste | tmux load-buffer - && tmux paste-buffer"

        # Theme-adaptive status bar — inherits colors from terminal
        set -g status-style "bg=default,fg=default"
        set -g status-left "#[bold][#S] "
        set -g status-right "%H:%M"
        set -g status-left-length 20
        set -g window-status-current-format "#[bold]#I:#W"
        set -g window-status-format "#[dim]#I:#W"
        set -g pane-border-style "fg=colour8"
        set -g pane-active-border-style "fg=colour4"
        set -g message-style "bg=default,fg=default,bold"
      '';
    };
  };
}
