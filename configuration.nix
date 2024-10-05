{ config, lib, pkgs, ... }:

{
  # List packages installed in system profile (All users)
  environment.systemPackages = with pkgs; [
    vim
    curl
    fzf
    git
  ];

  environment.shells = [ pkgs.zsh pkgs.bash ];
  environment.loginShell = pkgs.zsh;

  users.users.mattietea.home = "/Users/mattietea";
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;


  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  nix.configureBuildUsers = true;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
