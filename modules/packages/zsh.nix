{
  lib,
  config,
  settings,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkForce;
  cfg = config.pkgs.zsh;
in
{
  options.pkgs.zsh.enable = mkEnableOption "Zsh shell";

  config = mkIf cfg.enable {
    programs.zsh.enable = true;
    programs.zsh.autocd = true;

    programs.zsh.shellAliases = {
      c = "clear";
      g = "${pkgs.git}/bin/git";
      cat = "${pkgs.bat}/bin/bat";
      code = "${settings.variables.VISUAL}";
      config = "cd ~/.config/nix";
      switch = "sudo darwin-rebuild switch --flake .";
    };

    programs.zsh.plugins = with pkgs; [
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

    programs.zsh.enableCompletion = true;

    programs.zsh.initContent = ''
      zstyle ':completion:*' sort false
      setopt globdots
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
  };
}
