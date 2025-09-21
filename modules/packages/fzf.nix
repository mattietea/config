{
  pkgs,
  ...
}:

{
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;
  programs.fzf.defaultOptions = [
    "--height 40%"
    "--layout=reverse"
    "--inline-info"
  ];
  programs.fzf.fileWidgetOptions = [
    "--height 100%"
    "--layout=reverse"
    "--inline-info"
    "--preview '${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:500 --wrap=auto {}'"
    "--border=none"
    "--preview-window=noborder"
  ];
  programs.fzf.changeDirWidgetOptions = [
    "--height 100%"
    "--inline-info"
    "--preview '${pkgs.eza}/bin/eza --tree --color=always --icons {}'"
    "--border=none"
    "--preview-window=noborder"
  ];
}
