---
name: home-manager
description: "Home-manager module patterns for installing and configuring tools. Always prefer programs.* over home.packages. Use when adding new tools, configuring CLI/GUI apps, setting up shell integrations, or managing cross-tool references in this dotfiles repo."
---

# Home Manager Modules

Always prefer `programs.*` over `home.packages`. Use the NixOS MCP to check if home-manager has a module before falling back.

## Adding a New Tool

1. **Search home-manager**: `mcp__nixos__nix(action="search", source="home-manager", type="programs", query="<tool>")`
2. **Has `programs.<tool>.enable`?** Use the `programs.*` template
3. **No module?** Use the `home.packages` fallback
4. **Create** `modules/home-manager/packages/<tool>/default.nix`
5. **Add** `(pkg "tool")` to both `hosts/personal.nix` and `hosts/work.nix`

## Template: with home-manager module (preferred)

```nix
{
  pkgs,
  ...
}:
{
  programs.tool = {
    enable = true;
    enableZshIntegration = true;  # if available — usually want true
    settings = { };               # if available — declarative config
  };
}
```

Common options: `enable`, `package`, `enableZshIntegration`, `enableGitIntegration`, `settings`.

## Template: without home-manager module (fallback)

```nix
{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.tool ];
}
```

## Template: with settings or external inputs

```nix
{
  pkgs,
  settings,
  inputs,
  ...
}:
{
  programs.tool = {
    enable = true;
    package = inputs.tool-flake.packages.${pkgs.system}.default;
  };
}
```

## Cross-Tool References

Always use `${pkgs.tool}/bin/tool` — never hardcode paths.

```nix
fileWidgetOptions = [
  "--preview '${pkgs.bat}/bin/bat --color=always {}'"
];
shellAliases = {
  cat = "${pkgs.bat}/bin/bat";
};
```

## Gotchas

- One `programs` block per module — statix errors on repeated attribute keys
- `enableZshIntegration` provides aliases and completions — usually want `true`
- `home.activation` for imperative actions: use `lib.hm.dag.entryAfter [ "writeBoundary" ]`
