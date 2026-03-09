{
  inputs,
  pkgs,
  ...
}:
{
  programs.opencode = {
    enable = true;
    package = inputs.opencode.packages.${pkgs.system}.default;
    enableMcpIntegration = true;
    settings = {
      autoshare = false;
      plugin = [
        "oh-my-opencode"
      ];
    };
  };
}
