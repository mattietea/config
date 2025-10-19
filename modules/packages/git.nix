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

      settings = {
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };

        alias = {
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
          # Enables commit-graph for faster log/blame operations
          # https://git-scm.com/docs/git-config#Documentation/git-config.txt-corecommitGraph
          commitGraph = true;
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
        pack = {
          threads = 0;
          # Enable bitmap indexes for faster fetches
          # https://git-scm.com/docs/git-config#Documentation/git-config.txt-packwriteBitmaps
          writeBitmaps = true;
          # Limit individual pack file size to 2GB for better performance
          # https://git-scm.com/docs/git-config#Documentation/git-config.txt-packpackSizeLimit
          packSizeLimit = "2g";
          # Allow more memory for better pack compression
          # https://git-scm.com/docs/git-config#Documentation/git-config.txt-packwindowMemory
          windowMemory = "1g";
        };
        # Faster network operations (fetch/push)
        # https://git-scm.com/docs/git-config#Documentation/git-config.txt-protocolversion
        protocol.version = 2;
        # Trigger auto-gc less frequently (default 6700, was 256)
        # Lower values cause frequent gc which can slow operations
        # https://git-scm.com/docs/git-config#Documentation/git-config.txt-gcauto
        gc.auto = 6700;
        # Enable background maintenance with incremental strategy
        # Runs hourly: prefetch, commit-graph
        # Daily: loose-objects, incremental-repack
        # Weekly: pack-refs
        # https://git-scm.com/docs/git-config#Documentation/git-config.txt-maintenancestrategy
        maintenance = {
          auto = true;
          strategy = "incremental";
          autoDetach = true;
        };
        feature.manyFiles = true;
        github.user = settings.username;
        lfs.setlockablereadonly = 0;
        pull.rebase = true;
        fetch = {
          prune = true;
          prunetags = true;
          # Parallel submodule fetches (0 = auto-detect CPU cores)
          # https://git-scm.com/docs/git-config#Documentation/git-config.txt-fetchparallel
          parallel = 0;
          # Update commit-graph during fetch for faster operations
          # https://git-scm.com/docs/git-config#Documentation/git-config.txt-fetchwriteCommitGraph
          writeCommitGraph = true;
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
        };
        diff.algorithm = "histogram";
        status.showUntrackedFiles = "normal";
      };
    };
  };
}
