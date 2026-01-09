{
  lib,
  pkgs,
  ...
}:
{
  programs.zoxide = {
    enable = true;
    enableZshIntegration = false; # manually init at end of zshrc
    options = [ "--cmd cd" ];
  };

  programs.zsh.initContent = lib.mkOrder 1500 ''
    eval "$(${pkgs.zoxide}/bin/zoxide init --cmd cd zsh)"
  '';
}
