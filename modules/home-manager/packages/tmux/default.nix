_: {
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    historyLimit = 10000;
    mouse = true;
    keyMode = "vi";
    escapeTime = 0;
    baseIndex = 1;
    clock24 = true;

    extraConfig = ''
      # Copy tmux selections into the macOS clipboard.
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "/usr/bin/pbcopy"

      # Paste directly from the macOS clipboard.
      bind-key ] run-shell "/usr/bin/pbpaste | tmux load-buffer - && tmux paste-buffer"
    '';
  };
}
