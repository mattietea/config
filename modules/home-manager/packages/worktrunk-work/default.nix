{
  pkgs,
  ...
}:
{
  imports = [ ../worktrunk ];

  xdg.configFile."worktrunk/config.toml".text = ''
    worktree-path = "{{ repo_path }}/../{{ branch | sanitize }}"

    [pre-start]
    rebase = "git fetch {{ remote }} {{ default_branch }} && git rebase {{ remote }}/{{ default_branch }}"

    [projects."github.com/harveyai/frontend".post-start]
    copy-env = "${pkgs.worktrunk}/bin/wt step copy-ignored"
    install = "${pkgs.mise}/bin/mise exec node@22 -- pnpm install"
  '';
}
