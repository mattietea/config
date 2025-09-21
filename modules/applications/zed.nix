{
  pkgs,
  ...
}:

{

  home.packages = with pkgs; [
    nixfmt-rfc-style
    nixd
  ];

  # https://home-manager-options.extranix.com/?query=programs.zed&release=master

  programs.zed-editor = {
    enable = true;

    extensions = [
      "nix"
      "git-firefly"
      "tokyo-night"
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

      base_keymap = "VSCode";

      ui_font_size = 12;
      buffer_font_size = 12;

      minimap = {
        show = "never";
      };

      terminal = {
        font_size = 12;
      };

      project_panel = {
        auto_reveal_entries = false;
        hide_gitignore = false;
      };

      buffer_font_family = "JetBrainsMono Nerd Font";

      theme = {
        mode = "system";
        light = "One Light";
        dark = "Tokyo Night";
      };

      languages = {
        Nix = {
          language_servers = [
            "nixd"
          ];
        };
        JavaScript = {
          code_actions_on_format = {
            "source.fixAll.eslint" = true;
          };
        };
        TypeScript = {
          code_actions_on_format = {
            "source.fixAll.eslint" = true;
          };
        };
      };

      lsp = {
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
