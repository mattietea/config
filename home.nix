{ config, lib, pkgs, ... }:

{
  home.stateVersion = "24.05";

  programs.git = {
    enable = true;
    userName = "mattietea";
    userEmail = "mattcthomas@me.com";
    extraConfig = {
      github.user = "mattietea";
      init = { defaultBranch = "main"; };
    };
  };

  programs.zsh = {
    enable = true;

    # Automatically enter into a directory if typed directly into shell.
    autocd = true;

    # List of paths to autocomplete calls to cd.
    cdpath = ["~/Documents" "~/Downloads" "~/Desktop"];

    # Enable zsh autosuggestions
    autosuggestion = {
      enable = false;
    };

    # Options related to commands history configuration.
    history = {
      size = 10000000;
      save = 10000000;

      # Do not enter command lines into the history list if the first character is a space.
      ignoreSpace = true;
      ignoreDups = true;
      ignoreAllDups = true;
      expireDuplicatesFirst = true;
      extended = true;

      # Share command history between zsh sessions.
      share = true;
    };

    # Options related to the history substring search.
    historySubstringSearch = {
      enable = true;
      searchDownKey = "^[[B";
      searchUpKey = "^[[A";
    };

    # initExtraFirst = ''
    #   autoload -Uz _omz_register_handler
    #   zstyle ':omz:alpha:lib:git' async-prompt no 
    # '';

    # oh-my-zsh = {
    #   enable = true;
    #   plugins = [
    #     "git"
    #   ];
    #   theme = "frisk";
    #   extraConfig = ''
    #     export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
    #     eval $(/opt/homebrew/bin/brew shellenv)
    #   '';
    # };

    # profileExtra = ''
    #   # eval $(/opt/homebrew/bin/brew shellenv) # Set PATH, MANPATH, etc., for Homebrew.
    # '';
    syntaxHighlighting.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [ "--height 40%" "--layout=reverse" "--border" "--inline-info" ];
  };

  programs.zsh.shellAliases = {
    ls = "eza";
  };

  programs.zsh.oh-my-zsh.enable = true;
  programs.zsh.zplug = {
    enable = true;
    plugins = [
      { name = "zsh-users/zsh-autosuggestions"; }
      { name = "zdharma-continuum/fast-syntax-highlighting"; }
      { name = "zsh-users/zsh-completions"; }
      { name = "plugins/git"; tags = [ "from:oh-my-zsh" ]; }
      # { name = "dracula/zsh"; tags = ["as:theme"]; }
    ];
  };

  programs.eza = {
    enable = true;
    icons = true;
    extraOptions = [ "--group-directories-first" "--header" ];
    git = true;
  };

  programs.starship = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
}
