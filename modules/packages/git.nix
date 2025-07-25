{ settings
, pkgs
, ...
}:

{
  programs.git.enable = true;
  programs.git.userName = settings.username;
  programs.git.userEmail = settings.email;
  programs.git.delta.enable = true;

  programs.git.aliases = {
    amend = "commit --amend";
    commend = "commit --amend --no-edit";

    uncommit = "reset --mixed HEAD~";
    unstage = "reset HEAD --";
    undo = "reset --soft";

    fixup = "commit --fixup";
    tidy = "rebase --interactive";

    nevermind = "!git reset --hard HEAD && git clean -d -f";

    # Don't need fzf with marlonrichert/zsh-autocomplete
    # fixup = "!git log -n 50 --pretty=format:'%h %s' --no-merges | fzf | cut -c -7 | xargs -o git commit --fixup";
    # tidy = "!git log -n 50 --pretty=format:'%h %s' | fzf | cut -c -7 | xargs -o git rebase --interactive";
  };

  # https://jvns.ca/blog/2024/02/16/popular-git-config-options
  programs.git.extraConfig = {
    init = {
      defaultBranch = "main";
    };
    core = {
      editor = "${settings.variables.VISUAL}";
      fsmonitor = true;
      fscache = true;
      preloadindex = true;
    };
    gc = {
      auto = 256;
    };
    feature = {
      manyFiles = true;
    };
    github = {
      user = settings.username;
    };
    lfs = {
      setlockablereadonly = 0;
    };
    pull = {
      rebase = true;
    };
    fetch = {
      prune = true;
      prunetags = true;
    };
    push = {
      autoSetupRemote = true;
    };
    commit = {
      verbose = true;
    };
    merge = {
      # https://www.ductile.systems/zdiff3/
      conflictStyle = "zdiff3";
    };
    rerere = {
      enabled = true;
    };
    rebase = {
      autosquash = true;
      autostash = true;
      updateRefs = true;
    };
    diff = {
      algorithm = "histogram";
    };
  };
}
