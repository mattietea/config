_:
{
  programs.zsh.initContent = ''
    [ -f /opt/dev/dev.sh ] && source /opt/dev/dev.sh
    [[ -x /usr/local/bin/brew ]] && eval $(/usr/local/bin/brew shellenv)
    [[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)
    [[ -f /opt/dev/sh/chruby/chruby.sh ]] && { type chruby >/dev/null 2>&1 || chruby () { source /opt/dev/sh/chruby/chruby.sh; chruby "$@"; } }
  '';
}
