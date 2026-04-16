{
  pkgs,
  inputs,
  ...
}:
{
  programs.claude-code = {
    enable = true;
    package = inputs.claude-code-nix.packages.${pkgs.system}.claude-code;
    enableMcpIntegration = true;
    settings = {
      # Model & Mode
      model = "opus[1m]";
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
        "claude-mem@thedotmack" = true;
        "codex@openai-codex" = true;
        "improve-claude-md@skills" = true;
        "superpowers@claude-plugins-official" = true;
      };
      extraKnownMarketplaces = {
        thedotmack = {
          source = {
            source = "github";
            repo = "thedotmack/claude-mem";
          };
        };
        openai-codex = {
          source = {
            source = "github";
            repo = "openai/codex-plugin-cc";
          };
        };
        skills = {
          source = {
            source = "github";
            repo = "humanlayer/skills";
          };
        };
      };
    };
  };
}
