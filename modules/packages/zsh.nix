{ settings
, pkgs
, lib
, ...
}:
{
  # https://home-manager-options.extranix.com/?query=programs.zsh.&release=master

  programs.zsh.enable = true;
  programs.zsh.autocd = true;

  programs.zsh.cdpath = [
    "~/Documents"
    "~/Downloads"
    "~/Desktop"
  ];

  # programs.zsh.zprof.enable = true;

  programs.zsh.shellAliases = {
    c = "clear";
    g = "${pkgs.git}/bin/git";
    cat = "${pkgs.bat}/bin/bat";
    code = "${settings.variables.VISUAL}";
  };

  programs.zsh.plugins = with pkgs; [
    {
      name = "fast-syntax-highlighting";
      src = zsh-fast-syntax-highlighting;
      file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
    }
    # {
    #   name = "zsh-autocomplete";
    #   src = zsh-autocomplete;
    #   file = "share/zsh-autocomplete/zsh-autocomplete.plugin.zsh";
    # }
  ];

  programs.zsh.enableCompletion = lib.mkForce false;

  programs.zsh.initContent = ''
    # See https://github.com/zsh-users/zsh/blob/master/Completion/compinit#L67-L72
    zstyle '*:compinit' arguments -u

    # Enable hidden files in autocomplete
    setopt globdots

    # --------------------------------------------------------------------------
    # zsh-autocomplete
    # --------------------------------------------------------------------------
    # See https://github.com/marlonrichert/zsh-autocomplete/issues/750
    # setopt interactivecomments

    # bindkey              '^I' menu-select
    # bindkey "$terminfo[kcbt]" menu-select


    # bindkey -M menuselect              '^I' menu-select
    # bindkey -M menuselect "$terminfo[kcbt]" menu-select

    zstyle ':completion:*' completer _complete _complete:-fuzzy _correct _approximate _ignored
  '';

  programs.zsh.sessionVariables = settings.variables;

  programs.zsh.history.size = 10000000;
  programs.zsh.history.save = 10000000;
  programs.zsh.history.ignoreSpace = true;
  programs.zsh.history.ignoreDups = true;
  programs.zsh.history.ignoreAllDups = true;
  programs.zsh.history.expireDuplicatesFirst = true;
  programs.zsh.history.extended = true;
  programs.zsh.history.share = true;
}
