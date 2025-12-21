{ pkgs
, ...
}:
{
  programs = {
    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
    };

    zsh = {
      shellAliases = {
        ls = "${pkgs.eza}/bin/eza --oneline --icons --git";
        l = "ls --all";
        la = "l";
        tree = "ls --tree";
      };

      initContent = ''
        # When we change directory, run the ls command
        function chpwd() {
          emulate -L zsh
          ${pkgs.eza}/bin/eza --grid --icons --git;
        }
      '';
    };
  };
}
