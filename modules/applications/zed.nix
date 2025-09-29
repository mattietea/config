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
      "biome"
    ];

    userKeymaps = [
      {
        context = "Editor";
        bindings = {
          cmd-shift-i = "editor::SplitSelectionIntoLines";
        };
      }
      {
        context = "Workspace";
        bindings = {
          cmd-1 = "workspace::ToggleLeftDock";
          cmd-2 = "workspace::ToggleBottomDock";
          cmd-3 = [
            "task::Spawn"
            {
              task_name = "lazygit";
              target = "center";
            }
          ];
          cmd-shift-b = "pane::RevealInProjectPanel";
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

      agent = {
        always_allow_tool_actions = true;
        notify_when_agent_waiting = "all_screens";
        play_sound_when_agent_done = true;
      };

      base_keymap = "VSCode";

      ui_font_size = 12;
      buffer_font_size = 13;
      buffer_font_family = "Hack Nerd Font Mono";

      terminal = {
        font_size = 12;
      };

      minimap = {
        show = "never";
      };

      project_panel = {
        auto_reveal_entries = false;
        hide_gitignore = false;
      };

      theme = {
        mode = "system";
        light = "One Light";
        dark = "Github Dark";
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
