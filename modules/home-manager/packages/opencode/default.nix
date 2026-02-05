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
    # Hephaestus requires GPT-5.2-Codex (OpenAI only) — disable for Anthropic
    disabled_agents = [ "hephaestus" ];
    agents = {
      # Primary orchestrator (Opus per official docs)
      Sisyphus.model = "anthropic/claude-opus-4-6";
      sisyphus-junior.model = "anthropic/claude-sonnet-4-5";

      # Plan execution orchestrator (Sonnet per official docs)
      atlas.model = "anthropic/claude-sonnet-4-5";

      # Planning & strategy (Opus per official docs)
      prometheus.model = "anthropic/claude-opus-4-6";
      metis.model = "anthropic/claude-opus-4-6";
      momus.model = "anthropic/claude-opus-4-6";

      # Architecture & debugging (Opus per official docs)
      oracle.model = "anthropic/claude-opus-4-6";

      # Search & research (Haiku for explore, Sonnet for librarian per official docs)
      explore.model = "anthropic/claude-haiku-4-5";
      librarian.model = "anthropic/claude-sonnet-4-5";

      # Specialized agents
      frontend-ui-ux-engineer.model = "anthropic/claude-sonnet-4-5";
      document-writer.model = "anthropic/claude-sonnet-4-5";
      multimodal-looker.model = "anthropic/claude-haiku-4-5";
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
