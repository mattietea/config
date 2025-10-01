{
  pkgs,
  ...
}:

{

  home.packages = with pkgs; [
    nixfmt-rfc-style
    nixd
    nil
  ];

  # https://home-manager-options.extranix.com/?query=programs.zed&release=master

  programs.zed-editor = {
    enable = true;

    extensions = [
      "nix"
      "git-firefly"
      "tokyo-night"
      "github-theme"
      # "biome"
    ];

    userKeymaps = [
      {
        context = "Editor";
        bindings = {
          alt-shift-i = "editor::SplitSelectionIntoLines";
        };
      }
      {
        context = "Editor";
        bindings = {
          "ctrl-right" = "agent::QuoteSelection";
        };
      }
      {
        context = "!ProjectPanel";
        bindings = {
          cmd-1 = "pane::RevealInProjectPanel";
        };
      }
      {
        context = "ProjectPanel";
        bindings = {
          cmd-1 = "workspace::ToggleLeftDock";
        };
      }
      {
        context = "Editor";
        bindings = {
          "ctrl-right" = "agent::QuoteSelection";
        };
      }
      {
        context = "Workspace";
        bindings = {
          cmd-2 = "workspace::ToggleBottomDock";
          cmd-3 = [
            "task::Spawn"
            {
              task_name = "lazygit";
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
        label = "lazygit";
        command = "lazygit";
        cwd = "\${ZED_WORKTREE_ROOT}";
        hide = "on_success";
        reveal_target = "center";
        use_new_terminal = true;
        allow_concurrent_runs = false;
      }
    ];

    userSettings = {

      base_keymap = "VSCode";

      ui_font_size = 12;
      buffer_font_size = 13;
      buffer_font_family = "Hack Nerd Font Mono";
      excerpt_context_lines = 5;
      multi_cursor_modifier = "cmd_or_ctrl";
      seed_search_query_from_cursor = "selection";
      use_smartcase_search = true;
      show_call_status_icon = false;
      tab_size = 2;

      agent = {
        always_allow_tool_actions = true;
        notify_when_agent_waiting = "all_screens";
        play_sound_when_agent_done = true;
      };

      file_finder = {
        modal_max_width = "small";
      };

      terminal = {
        font_size = 12;
      };

      minimap = {
        show = "never";
      };

      tabs = {
        git_status = true;
      };

      project_panel = {
        auto_reveal_entries = false;
        hide_gitignore = false;

      };

      collaboration_panel = {
        button = false;
      };

      git_panel = {
        sort_by_path = true;
      };

      theme = {
        mode = "system";
        light = "One Light";
        dark = "Github Dark";
      };

      git = {
        branch_picker = {
          show_author_name = true;
        };
      };

      languages = {
        Nix = {
          language_servers = [
            "nixd"
            "nil"
          ];
        };
      };

      lsp = {
        biome = {
          settings = {
            require_config_file = true;
          };
        };
        nil = {
          settings = {
            diagnostics = {
              ignored = [ "unused_binding" ];
            };
          };
        };
        nixd = {
          binary = {
            path = "${pkgs.nixd}/bin/nixd";
          };
          settings = {
            diagnostic = {
              suppress = [ "sema-extra-with" ];
            };
          };
        };
      };
    };
  };

}
