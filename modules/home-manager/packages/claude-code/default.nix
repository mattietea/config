{
  pkgs,
  inputs,
  ...
}:
{
  # Required for macOS desktop notifications
  home.packages = [
    pkgs.terminal-notifier
  ];

  programs.claude-code = {
    enable = true;
    package = inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
    enableMcpIntegration = true;
    settings = {
      # Model & Mode
      model = "opusplan";
      effortLevel = "high";
      defaultMode = "plan";

      # UI Settings
      theme = "ansi-light";
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
      env = {
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
        BASH_DEFAULT_TIMEOUT_MS = "30000";
        FORCE_AUTOUPDATE_PLUGINS = "true";
      };
      autoConnectIde = true;
      claudeInChromeDefaultEnabled = true;
      attribution = {
        commit = "";
        pr = "";
      };
      enabledPlugins = {
        "code-simplifier@claude-plugins-official" = true;
        "claude-notifications-go@claude-notifications-go" = true;
      };
      extraKnownMarketplaces = {
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
    };
  };
}
