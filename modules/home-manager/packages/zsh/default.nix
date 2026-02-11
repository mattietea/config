{
  settings,
  pkgs,
  ...
}:
{
  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;

    shellAliases = {
      c = "clear";
      g = "${pkgs.git}/bin/git";
      cat = "${pkgs.bat}/bin/bat";
      code = "${settings.variables.VISUAL}";
      config = "cd ~/.config/nix";
      claude = "claude --dangerously-skip-permissions";
    };

    plugins = [
      {
        name = "fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
      }
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    enableCompletion = true;

    initContent = ''
      zstyle ':completion:*' sort false
      setopt globdots

      # fzf-tab: switch between groups with , and .
      zstyle ':fzf-tab:*' switch-group ',' '.'

      # For git commands: reverse order so commits appear first (they're generated last by zsh)
      zstyle ':fzf-tab:complete:git-*:*' fzf-flags --tac
    '';

    sessionVariables = settings.variables // {
      MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
    };

    history = {
      size = 10000000;
      save = 10000000;
      ignoreSpace = true;
      ignoreDups = true;
      ignoreAllDups = true;
      expireDuplicatesFirst = true;
      extended = true;
      share = true;
    };
  };
}
