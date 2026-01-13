{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  utils = import ./utilities.nix { inherit lib; };
  ai = import ../../ai;

  ohMyOpencodeConfig = {
    "$schema" =
      "https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json";
    google_auth = false;
    ralph_loop = {
      enabled = true;
      default_max_iterations = 100;
    };
    agents = {
      Sisyphus.model = "anthropic/claude-opus-4-5";
      oracle.model = "anthropic/claude-sonnet-4-5";
      librarian.model = "anthropic/claude-sonnet-4-5";
      explore.model = "anthropic/claude-haiku-4-5";
      frontend-ui-ux-engineer.model = "anthropic/claude-sonnet-4-5";
      document-writer.model = "anthropic/claude-sonnet-4-5";
      multimodal-looker.model = "anthropic/claude-sonnet-4-5";
    };
  };
in
{
  # Required for macOS desktop notifications
  home.packages = [ pkgs.terminal-notifier ];

  programs.opencode = {
    enable = true;
    package = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
      autoshare = false;
      mcp = utils.mcpServers;
      plugin = [
        "oh-my-opencode"
        "@mohak34/opencode-notifier@latest"
      ];
    };
    inherit (ai) rules agents;
  };

  home.file.".config/opencode/oh-my-opencode.json".text = builtins.toJSON ohMyOpencodeConfig;
}
