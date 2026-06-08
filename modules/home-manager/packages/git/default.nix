{
  settings,
  pkgs,
  ...
}:
{
  programs.git = {
    enable = true;
    lfs.enable = true;

    ignores = [
      ".DS_Store"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      ".sisyphus"
      "docs/superpowers/"
    ];

    settings = {
      user = {
        inherit (settings) name email;
      };

      alias = {
        amend = "commit --amend";
        commend = "commit --amend --no-edit";
        unstage = "restore --staged";
        undo = "reset --soft HEAD~";
        wipe = "!git reset --hard HEAD && git clean -dfx";
        lazy = "!${pkgs.lazygit}/bin/lazygit";
        fixup = "commit --fixup";
        tidy = "rebase --interactive --autosquash";
        tree = "!${pkgs.worktrunk}/bin/wt";
        bare = "!${pkgs.writeShellScript "git-bare" ''
          set -euo pipefail
          url="$1"
          dir="''${2:-$(basename "$url" .git)}"
          mkdir -p "$dir" && cd "$dir"
          ${pkgs.git}/bin/git clone --bare "$url" .bare
          echo "gitdir: ./.bare" > .git
          ${pkgs.git}/bin/git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
          ${pkgs.git}/bin/git fetch origin
          default_branch=$(${pkgs.git}/bin/git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null)
          default_branch="''${default_branch##refs/remotes/origin/}"
          : "''${default_branch:=main}"
          ${pkgs.git}/bin/git worktree add "$default_branch"
          echo "Set up bare clone in $dir/ with worktree for $default_branch"
        ''}";
      };

      init.defaultBranch = "main";
      core = {
        editor = "${settings.variables.VISUAL}";
        # fsmonitor can misbehave on network filesystems (NFS/SMB/FUSE).
        fsmonitor = true;
        preloadindex = true;
        untrackedCache = true;
        commitGraph = true;
      };
      branch = {
        autoSetupMerge = "simple";
        autoSetupRebase = "always";
      };
      index = {
        threads = 0;
        version = 4;
        sparse = true;
      };
      pack = {
        threads = 0;
        writeBitmaps = true;
        packSizeLimit = "2g";
        windowMemory = "1g";
      };
      protocol.version = 2;
      gc.auto = 6700;
      maintenance = {
        auto = true;
        strategy = "incremental";
        autoDetach = true;
      };
      feature.manyFiles = true;
      github.user = settings.github;
      lfs.setlockablereadonly = 0;
      pull.rebase = true;
      fetch = {
        prune = true;
        prunetags = true;
        parallel = 0;
        writeCommitGraph = true;
        output = "compact";
      };
      push = {
        autoSetupRemote = true;
        default = "simple";
      };
      commit.verbose = true;
      merge = {
        conflictStyle = "zdiff3";
        stat = false;
      };
      rerere.enabled = true;
      mergetool.hideResolved = true;
      rebase = {
        updateRefs = true;
        autosquash = true;
        autostash = true;
        stat = false;
      };
      diff.algorithm = "histogram";
      diff.colorMoved = "default";
      status.showUntrackedFiles = "normal";
      advice = {
        statusHints = false;
        pushNonFastForward = false;
        detachedHead = false;
      };
      submodule = {
        fetchJobs = 0;
        recurse = false;
      };
      worktree.guessRemote = true;
      column.ui = "auto";
    };
  };
}
