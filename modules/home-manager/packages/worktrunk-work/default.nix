{
  pkgs,
  ...
}:
{
  imports = [ ../worktrunk ];

  home.file.".config/worktrunk/config.toml".text = ''
    worktree-path = "{{ repo_path }}/../{{ branch | sanitize }}"

    [projects."github.com/harveyai/frontend"]
    hooks.post-start = "${pkgs.yarn}/bin/yarn install"
    hooks.post-switch = "${pkgs.yarn}/bin/yarn install"
  '';
}
