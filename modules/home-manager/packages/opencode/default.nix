{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  utils = import ./utilities.nix { inherit lib; };
  ai = import ../../ai;
in
{
  programs.opencode = {
    enable = true;
    package = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
      autoshare = false;
      mcp = utils.mcpServers;
    };
    inherit (ai) rules agents;
  };
}
