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
        unstage = "restore --staged";
        undo = "reset --soft HEAD~";
        wipe = "!git reset --hard HEAD && git clean -dfx";
        lazy = "!${pkgs.lazygit}/bin/lazygit";
        fixup = "!git log -n 50 --pretty=format:'%h %s' --no-merges | fzf --no-sort | awk '{print $1}' | xargs -o git commit --fixup";
        tidy = "!git log -n 50 --pretty=format:'%h %s' --no-merges | fzf --no-sort | awk '{print $1}' | xargs -o git rebase --interactive --autosquash";
      };

      # https://jvns.ca/blog/2024/02/16/popular-git-config-options
      extraConfig = {
        init.defaultBranch = "main";
        core = {
          editor = "${settings.variables.VISUAL}";
          # Monitors filesystem changes for faster status checks
          # https://git-scm.com/docs/git-config#Documentation/git-config.txt-corefsmonitor
          fsmonitor = true;
          # Parallel index preloading for faster operations
          # https://git-scm.com/docs/git-config#Documentation/git-config.txt-corepreloadIndex
          preloadindex = true;
          pager = "${pkgs.delta}/bin/delta";
          # Caches untracked files for faster status
          # https://git-scm.com/docs/git-config#Documentation/git-config.txt-coreuntrackedCache
          untrackedCache = true;
        };
        index = {
          # Use all CPU cores for index operations (0 = auto-detect)
          # https://git-scm.com/docs/git-config#Documentation/git-config.txt-indexthreads
          threads = 0;
          # More efficient index format (smaller, faster)
          # https://git-scm.com/docs/git-config#Documentation/git-config.txt-indexversion
          version = 4;
        };
        # Parallel packing during gc and push operations
        # https://git-scm.com/docs/git-config#Documentation/git-config.txt-packthreads
        pack.threads = 0;
        # Faster network operations (fetch/push)
        # https://git-scm.com/docs/git-config#Documentation/git-config.txt-protocolversion
        protocol.version = 2;
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
        status.showUntrackedFiles = "normal";
      };
    };
  };
}
