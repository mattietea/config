{
  settings,
  pkgs,
  lib,
  ...
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

  programs.zsh.shellAliases = {
    c = "clear";
    g = "${pkgs.git}/bin/git";
    cat = "${pkgs.bat}/bin/bat";
    code = "${settings.variables.VISUAL}";
  };

  # Notice we are using the nixpkgs package for these
  # this is so Nix can manage their installs and remove them
  # when they are no longer used.
  programs.zsh.plugins = with pkgs; [
    {
      name = "fast-syntax-highlighting";
      src = zsh-fast-syntax-highlighting;
      file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
    }
    {
      name = "zsh-you-should-use";
      src = zsh-you-should-use;
      file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
    }
    {
      name = "zsh-autocomplete";
      src = zsh-autocomplete;
      file = "share/zsh-autocomplete/zsh-autocomplete.plugin.zsh";
    }
  ];

  # Disable as 'zsh-autocoplete' calls this
  # as marlonrichert/zsh-autocomplete calls this for us
  programs.zsh.enableCompletion = lib.mkForce false;

  programs.zsh.initExtra = ''
    # See https://github.com/zsh-users/zsh/blob/master/Completion/compinit#L67-L72
    zstyle '*:compinit' arguments -u

    # See https://github.com/marlonrichert/zsh-autocomplete/issues/750
    setopt interactive_comments

    # zsh autocomplete, make tab and shift tab change the selection in the menu
    bindkey '^I' menu-complete
    bindkey "$terminfo[kcbt]" reverse-menu-complete

    # zsh autocomplete, make tab and shift tab change the selection in the menu
    bindkey -M menuselect '^I' menu-complete
    bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete

    # TODO: Fix this
    # Currently needed for Shopify
    [ -f /opt/dev/dev.sh ] && source /opt/dev/dev.sh
    [[ -x /usr/local/bin/brew ]] && eval $(/usr/local/bin/brew shellenv)
    [[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)
    [[ -f /opt/dev/sh/chruby/chruby.sh ]] && { type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; } }
  '';

  programs.zsh.sessionVariables = settings.variables // {
    # https://github.com/MichaelAquilina/zsh-you-should-use?tab=readme-ov-file#customising-messages
    YSU_MESSAGE_FORMAT = "⚠ $(tput setaf 3)%command$(tput sgr0) → $(tput setaf 2)%alias$(tput sgr0)";
  };

  programs.zsh.history.size = 10000000;
  programs.zsh.history.save = 10000000;
  programs.zsh.history.ignoreSpace = true;
  programs.zsh.history.ignoreDups = true;
  programs.zsh.history.ignoreAllDups = true;
  programs.zsh.history.expireDuplicatesFirst = true;
  programs.zsh.history.extended = true;
  programs.zsh.history.share = true;
}
