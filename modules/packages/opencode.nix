{ pkgs, ... }:

{
  # https://home-manager-options.extranix.com/?query=opencode&release=master

  programs.opencode = {
    enable = true;
    package = pkgs.opencode;
  };
}
