{
  pkgs,
  ...
}:
{
  imports = [ ../worktrunk ];

  home.file.".config/worktrunk/config.toml".text = ''
    worktree-path = "{{ repo_path }}/../{{ branch | sanitize }}"

    [projects."github.com/harveyai/frontend".post-create]
    copy = "${pkgs.worktrunk}/bin/wt step copy-ignored"
    symlink-superpowers = "rm -rf docs/superpowers && ln -s {{ primary_worktree_path }}/docs/superpowers docs/superpowers"
    install = "${pkgs.mise}/bin/mise exec node@22 -- sh -c 'yarn install && (cd word-add-in && yarn install) & (cd outlook-add-in && yarn install) & wait'"
  '';
}
