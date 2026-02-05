{
  pkgs,
  lib,
  ...
}:
let
  # Configured for Claude Max20 mode
  ohMyOpencodeConfig = {
    "$schema" =
      "https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json";
    google_auth = false;
    ralph_loop = {
      enabled = true;
      default_max_iterations = 100;
    };
    agents = {
      # Primary orchestrator - uses Opus 4.5 for max capability
      Sisyphus.model = "anthropic/claude-opus-4-5";
      sisyphus-junior.model = "anthropic/claude-sonnet-4-5";

      # Planning & strategy
      prometheus.model = "anthropic/claude-sonnet-4-5";
      metis.model = "anthropic/claude-sonnet-4-5";
      momus.model = "anthropic/claude-sonnet-4-5";

      # Architecture & debugging
      oracle.model = "anthropic/claude-sonnet-4-5";

      # Fast search & research
      explore.model = "anthropic/claude-haiku-4-5";
      librarian.model = "anthropic/claude-haiku-4-5";

      # Specialized agents
      frontend-ui-ux-engineer.model = "anthropic/claude-sonnet-4-5";
      document-writer.model = "anthropic/claude-sonnet-4-5";
      multimodal-looker.model = "anthropic/claude-sonnet-4-5";
      qa-tester.model = "anthropic/claude-sonnet-4-5";
    };
  };
in
{
  # Required for macOS desktop notifications
  home.packages = [ pkgs.terminal-notifier ];

  programs.opencode = {
    enable = true;
    package = pkgs.opencode;
    enableMcpIntegration = true;
    settings = {
      autoshare = false;
      plugin = [
        "oh-my-opencode"
        "@mohak34/opencode-notifier@latest"
      ];
    };
  };

  home.file.".config/opencode/oh-my-opencode.json".text = builtins.toJSON ohMyOpencodeConfig;
}
