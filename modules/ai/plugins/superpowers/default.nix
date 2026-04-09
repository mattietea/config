{
  inputs,
  ...
}:
{
  # OpenCode: install as plugin
  programs.opencode.settings.plugin = [
    "superpowers@git+https://github.com/obra/superpowers.git"
  ];

  # Codex: symlink skills directory for native skill discovery
  home.file.".agents/skills/superpowers".source = "${inputs.superpowers}/skills";
}
