{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkOption mkIf types;
  cfg = config.apps.zed;

  defaults = {
    base_keymap = "VSCode";
    ui_font_size = 13;
    buffer_font_size = 13;
    buffer_font_family = "JetBrainsMono Nerd Font";
    excerpt_context_lines = 5;
    seed_search_query_from_cursor = "selection";
    use_smartcase_search = true;
    show_call_status_icon = false;
    tab_size = 2;
    bottom_dock_layout = "left_aligned";
    agent = {
      always_allow_tool_actions = true;
      notify_when_agent_waiting = "all_screens";
      play_sound_when_agent_done = true;
      inline_assistant_model = {
        provider = "copilot_chat";
        model = "gpt-5-mini";
      };
    };
    agent_servers = {
      claude = { default_mode = "bypassPermissions"; };
    };
    minimap.show = "never";
    tabs.git_status = true;
    project_panel = {
      auto_reveal_entries = false;
      hide_gitignore = false;
    };
    collaboration_panel.button = false;
    git_panel.sort_by_path = true;
    theme = {
      mode = "system";
      light = "One Light";
      dark = "Github Dark";
    };
    terminal = {
      font_size = 14;
      max_scroll_history_lines = 100000;
    };
    git.branch_picker.show_author_name = true;
    languages.Nix.language_servers = [ "nixd" "nil" ];
    lsp = {
      biome.settings.require_config_file = true;
      nil.settings.diagnostics.ignored = [ "unused_binding" ];
      nixd = {
        binary.path = "${pkgs.nixd}/bin/nixd";
        settings.diagnostic.suppress = [ "sema-extra-with" ];
      };
    };
  };
in
{
  options.apps.zed = {
    enable = mkEnableOption "Zed editor";
    settings = mkOption { type = types.attrs; default = {}; };
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
    # useful editor/language tooling alongside zed
    home.packages = with pkgs; [ nixfmt-rfc-style nixd nil ];

    programs.zed-editor = {
      enable = true;
      extensions = [ "nix" "git-firefly" "tokyo-night" "github-theme" ];
      userSettings = defaults // cfg.settings;

      userKeymaps = [
        { context = "Editor"; bindings.alt-shift-i = "editor::SplitSelectionIntoLines"; }
        { context = "Editor"; bindings."ctrl-right" = "agent::QuoteSelection"; }
        { context = "!ProjectPanel"; bindings.cmd-1 = "pane::RevealInProjectPanel"; }
        { context = "ProjectPanel"; bindings.cmd-1 = "workspace::ToggleLeftDock"; }
        { context = "Editor"; bindings."ctrl-right" = "agent::QuoteSelection"; }
        {
          context = "Workspace";
          bindings = {
            cmd-2 = "workspace::ToggleBottomDock";
            cmd-3 = [
              "task::Spawn"
              { task_name = "LazyGit"; target = "center"; }
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
