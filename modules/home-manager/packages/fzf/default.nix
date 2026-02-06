{
  pkgs,
  ...
}:
{
  programs = {
    fd.enable = true;
    ripgrep.enable = true;

    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git";
      defaultOptions = [
        "--height 40%"
        "--layout=reverse"
        "--info=inline"
      ];
      fileWidgetCommand = "${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git";
      fileWidgetOptions = [
        "--height 100%"
        "--layout=reverse"
        "--info=inline"
        "--preview '${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:500 --wrap=auto {}'"
        "--border=none"
        "--preview-window=noborder"
      ];
      changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d --hidden --follow --exclude .git";
      changeDirWidgetOptions = [
        "--height 100%"
        "--info=inline"
        "--preview '${pkgs.eza}/bin/eza --tree --color=always --icons {}'"
        "--border=none"
        "--preview-window=noborder"
      ];
    };
  };
}
