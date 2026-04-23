{
  inputs,
  ...
}:
{
  # Codex: symlink skills directory for native skill discovery
  home.file.".agents/skills/superpowers".source = "${inputs.superpowers}/skills";
}
