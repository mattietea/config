{
  settings,
  pkgs,
  ...
}:
{
  programs.zsh = {
    enable = true;
    autocd = true;

    shellAliases = {
      c = "clear";
      g = "${pkgs.git}/bin/git";
      cat = "${pkgs.bat}/bin/bat";
      code = "${settings.variables.VISUAL}";
      config = "cd ~/.config/nix";
      cd = "${pkgs.zoxide}/bin/zoxide";
    };

    plugins = with pkgs; [
      {
        name = "fast-syntax-highlighting";
        src = zsh-fast-syntax-highlighting;
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
      }
      {
        name = "fzf-tab";
        src = zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    enableCompletion = true;

    initContent = ''
      zstyle ':completion:*' sort false
      setopt globdots
    '';

    sessionVariables = settings.variables;

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
