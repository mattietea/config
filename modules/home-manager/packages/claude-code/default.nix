{
  pkgs,
  inputs,
  ...
}:
{
  # Required for macOS desktop notifications and auto-memory plugin
  home.packages = [
    pkgs.terminal-notifier
    pkgs.python3
  ];

  programs.claude-code = {
    enable = true;
    package = inputs.claude-code-nix.packages.${pkgs.system}.default;
    enableMcpIntegration = true;
    settings = {
      # Model & Mode
      model = "opus";
      defaultMode = "plan";

      # UI Settings
      theme = "dark";
      terminalProgressBarEnabled = true;
      spinnerTipsEnabled = true;
      outputStyle = "default";
      codeDiffFooterEnabled = true;
      prStatusFooterEnabled = true;
      editorMode = "normal";

      # Features
      alwaysThinkingEnabled = true;
      autoCompactEnabled = true;
      promptSuggestionEnabled = true;
      fileCheckpointingEnabled = true;
      respectGitignore = true;
      enableAllProjectMcpServers = true;

      # Notifications (Ghostty OSC 777)
      notifChannel = "ghostty";

      # IDE Integration
      autoConnectIde = true;
      claudeInChromeDefaultEnabled = true;
      attribution = {
        commit = "";
        pr = "";
      };
      enabledPlugins = {
        "oh-my-claudecode@omc" = true;
        "auto-memory@severity1-marketplace" = true;
        "code-simplifier@claude-plugins-official" = true;
        "claude-notifications-go@claude-notifications-go" = true;
      };
      extraKnownMarketplaces = {
        omc = {
          source = {
            source = "github";
            repo = "Yeachan-Heo/oh-my-claudecode";
          };
        };
        severity1-marketplace = {
          source = {
            source = "github";
            repo = "severity1/severity1-marketplace";
          };
        };
        claude-plugins-official = {
          source = {
            source = "github";
            repo = "anthropics/claude-plugins-official";
          };
        };
        claude-notifications-go = {
          source = {
            source = "github";
            repo = "777genius/claude-notifications-go";
          };
        };
      };
      statusLine = {
        type = "command";
        command = "node ~/.claude/hud/omc-hud.mjs";
      };
    };
  };
}
