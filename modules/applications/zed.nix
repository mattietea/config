{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;
  cfg = config.apps.zed;
in
{
  options.apps.zed = {
    enable = mkEnableOption "Zed editor";
  };

  config = mkIf (cfg.enable) {
    # useful editor/language tooling alongside zed
    home.packages = with pkgs; [
      nixfmt-rfc-style
      nixd
      nil
    ];

    programs.zed-editor = {
      enable = true;
      extensions = [
        "nix"
        "git-firefly"
        "tokyo-night"
        "github-theme"
      ];
      userSettings = {
        lsp.nixd.binary.path = "${pkgs.nixd}/bin/nixd";
      };

      userKeymaps = [
        {
          context = "Editor";
          bindings.alt-shift-i = "editor::SplitSelectionIntoLines";
        }
        {
          context = "Editor";
          bindings."ctrl-right" = "agent::QuoteSelection";
        }
        {
          context = "!ProjectPanel";
          bindings.cmd-1 = "pane::RevealInProjectPanel";
        }
        {
          context = "ProjectPanel";
          bindings.cmd-1 = "workspace::ToggleLeftDock";
        }
        {
          context = "Editor";
          bindings."ctrl-right" = "agent::QuoteSelection";
        }
        {
          context = "Workspace";
          bindings = {
            cmd-2 = "workspace::ToggleBottomDock";
            cmd-3 = [
              "task::Spawn"
              {
                task_name = "LazyGit";
                target = "center";
              }
            ];
            cmd-shift-b = "pane::RevealInProjectPanel";
            "cmd-k l" = "dev::OpenLanguageServerLogs";
          };
        }
      ];

      userTasks = [
        {
          label = "LazyGit";
          command = "lazygit";
          cwd = "\${ZED_WORKTREE_ROOT}";
          hide = "on_success";
          reveal_target = "center";
          use_new_terminal = true;
          show_command = false;
          show_summary = false;
          allow_concurrent_runs = false;
        }
      ];
    };
  };
}
