{
  pkgs,
  ...
}:
{
  programs.codex = {
    enable = true;
    package = pkgs.codex;
    enableMcpIntegration = true;
    settings = {
      approval_policy = "never";
      model = "gpt-5.4";
      model_reasoning_effort = "high";
      sandbox_mode = "danger-full-access";
    };
  };
}
