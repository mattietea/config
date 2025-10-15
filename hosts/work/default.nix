{ mkDarwinHost }:

mkDarwinHost {
  hostname = "Matts-Work-MacBook-Pro";

  settings = {
    username = "mattietea";
    email = "mattcthomas@me.com";
    variables = {
      EDITOR = "zed --wait";
      VISUAL = "zed --wait";
    };
  };

  apps = {
    discord.enable = true;
    raycast.enable = true;
    spotify.enable = true;
    zed = {
      enable = true;
      userSettings = {
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
          nixd.settings.diagnostic.suppress = [ "sema-extra-with" ];
        };
      };
    };
  };

  packages = {
    bat.enable = true;
    delta.enable = true;
    dotenv.enable = true;
    eza.enable = true;
    fonts.enable = true;
    fzf.enable = true;
    gh.enable = true;
    git.enable = true;
    git-absorb.enable = true;
    git-machete.enable = true;
    graphite.enable = true;
    lazygit.enable = true;
    opencode.enable = true;
    pure.enable = true;
    rename-utils.enable = true;
    shopify.enable = true;
    tldr.enable = true;
    zsh.enable = true;
  };
}
