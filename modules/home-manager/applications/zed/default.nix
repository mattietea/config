{ lib, ... }:
{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "git-firefly"
      "github-theme"
      "opencode"
      "tsgo"
      "oxc"
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
        play_sound_when_agent_done = "always";
      };
      # Fullscreen file finder: no horizontal padding, whole viewport width.
      file_finder.modal_max_width = "full";
      minimap.show = "never";
      tabs.git_status = true;
      project_panel = {
        auto_reveal_entries = false;
        hide_gitignore = false;
      };
      collaboration_panel.button = false;
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
      # Type-aware oxlint rules (no-floating-promises etc., via tsgolint).
      # `options.typeAware = true` in an extended oxlint config doesn't reach
      # the language server, so it must be enabled as an LSP option — same
      # reason work's CLI scripts pass --type-aware explicitly.
      lsp.oxlint.initialization_options.settings.typeAware = true;
      languages =
        let
          # tsgo (typescript-go) instead of the legacy vtsls; oxlint for
          # diagnostics and oxfmt as formatter (both resolved from the
          # project's node_modules by the oxc extension, so repos without
          # them are unaffected).
          typescript = {
            language_servers = [
              "tsgo"
              "oxlint"
              "oxfmt"
              "!vtsls"
              "!typescript-language-server"
              "..."
            ];
            formatter.language_server.name = "oxfmt";
            code_actions_on_format."source.fixAll.oxc" = true;
          };
        in
        {
          TypeScript = typescript;
          TSX = typescript;
          JavaScript = typescript;
          JSX = typescript;
        };
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
      # ToggleFocus only shows/focuses a panel; it never hides one. Pressing
      # the same shortcut while the panel is focused should hide it and return
      # focus to the editor, so each panel's own context rebinds the shortcut
      # to toggle (close) its dock. These deeper contexts beat Workspace.
      {
        context = "ProjectPanel";
        bindings.cmd-1 = "workspace::ToggleLeftDock";
      }
      {
        context = "Terminal";
        bindings.cmd-2 = "workspace::ToggleBottomDock";
      }
      {
        # cmd-1/2 also need overriding here: defaults bind them to git tab
        # switching inside the git panel, which would shadow the Workspace
        # toggles (deeper context wins).
        context = "GitPanel";
        bindings = {
          cmd-1 = "project_panel::ToggleFocus";
          cmd-2 = "terminal_panel::ToggleFocus";
          cmd-3 = "workspace::ToggleLeftDock";
        };
      }
      {
        context = "AgentPanel";
        bindings.cmd-r = "workspace::ToggleRightDock";
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
