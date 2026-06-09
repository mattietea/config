{
  pkgs,
  ...
}:
{
  programs = {
    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };

    zsh = {
      shellAliases = {
        ls = "${pkgs.eza}/bin/eza --oneline --icons --git";
        l = "ls --all";
        la = "l";
        tree = "ls --tree";
      };

      initContent = ''
        # Auto-list on cd — but only in an interactive terminal. In scripts or
        # backgrounded shells (e.g. `zsh -c`, no controlling tty) eza would block
        # on SIGTTOU trying to write to the terminal and hang the whole shell.
        function chpwd() {
          emulate -L zsh
          [[ -o interactive && -t 1 ]] || return
          ${pkgs.eza}/bin/eza --grid --icons --git
        }
      '';
    };
  };
}
