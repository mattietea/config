{
  lib,
  settings,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  cfg = config.pkgs.git;
in
{
  options.pkgs.git = {
    enable = mkEnableOption "Git";
    userName = mkOption {
      type = types.str;
      default = settings.username;
    };
    userEmail = mkOption {
      type = types.str;
      default = settings.email;
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;

      aliases = {
        amend = "commit --amend";
        commend = "commit --amend --no-edit";
        unstage = "reset HEAD --";
        undo = "!git reset --soft HEAD~";
        nvm = "!git reset --hard HEAD && git clean -d -f";
        lazy = "!${pkgs.lazygit}/bin/lazygit";
        # Don't need fzf with marlonrichert/zsh-autocomplete
        fixup = "!git log -n 50 --pretty=format:'%h %s' --no-merges | fzf | cut -c -7 | xargs -o git commit --fixup";
        tidy = "!git log -n 50 --pretty=format:'%h %s' | fzf | cut -c -7 | xargs -o git rebase --interactive --autosquash";
      };

      # https://jvns.ca/blog/2024/02/16/popular-git-config-options
      extraConfig = {
        init.defaultBranch = "main";
        core = {
          editor = "${settings.variables.VISUAL}";
          fsmonitor = true;
          fscache = true;
          preloadindex = true;
          pager = "${pkgs.delta}/bin/delta";
          untrackedCache = true;
        };
        gc.auto = 256;
        feature.manyFiles = true;
        github.user = settings.username;
        lfs.setlockablereadonly = 0;
        pull.rebase = true;
        fetch = {
          prune = true;
          prunetags = true;
        };
        push = {
          autoSetupRemote = true;
          default = "simple";
        };
        commit.verbose = true;
        merge.conflictStyle = "zdiff3"; # https://www.ductile.systems/zdiff3/
        rerere.enabled = true;
        mergetool.hideResolved = true;
        rebase = {
          autosquash = true;
          autostash = true;
          updateRefs = true;
        };
        diff.algorithm = "histogram";
        status.showUntrackedFiles = "all";
      };
    };
  };
}
