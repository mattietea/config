_:
let
  baseConfig = import ../opencode/oh-my-opencode-base.nix;

  # Anthropic-only: disable hephaestus (requires OpenAI GPT-5.3-Codex)
  config = baseConfig // {
    disabled_agents = [ "hephaestus" ];
  };
in
{
  home.file.".config/opencode/oh-my-opencode.json".text = builtins.toJSON config;
}
