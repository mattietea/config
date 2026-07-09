{ lib, ... }:
{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "git-firefly"
      "github-theme"
      "opencode"
    ];
    userSettings = {
      base_keymap = "VSCode";
      ui_font_size = 14;
      buffer_font_size = 14;
      buffer_font_family = "JetBrainsMono Nerd Font";
      excerpt_context_lines = 5;
      seed_search_query_from_cursor = "selection";
      use_smartcase_search = true;
      show_call_status_icon = false;
      tab_size = 2;
      bottom_dock_layout = "left_aligned";
      agent = {
        notify_when_agent_waiting = "all_screens";
        play_sound_when_agent_done = true;
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
        dark = "GitHub Dark";
      };
      terminal = {
        font_size = 14;
        max_scroll_history_lines = 100000;
      };
      git.branch_picker.show_author_name = true;
    };
    userKeymaps = [
      {
        context = "Editor";
        bindings.alt-shift-i = "editor::SplitSelectionIntoLines";
      }

      {
        context = "Workspace";
        bindings = {
          cmd-1 = "project_panel::ToggleFocus";
          cmd-2 = "terminal_panel::ToggleFocus";
          cmd-3 = "git_panel::ToggleFocus";
          cmd-r = "agent::ToggleFocus";
          cmd-shift-b = "pane::RevealInProjectPanel";
          "cmd-k l" = "dev::OpenLanguageServerLogs";
        };
      }
      {
        # Defaults bind cmd-1/2 to git tab switching inside the git panel,
        # which would shadow the Workspace toggles (deeper context wins).
        context = "GitPanel";
        bindings = {
          cmd-1 = "project_panel::ToggleFocus";
          cmd-2 = "terminal_panel::ToggleFocus";
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
}
