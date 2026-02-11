{ settings, ... }:

{
  ##########################################################################
  # nix-darwin: macOS system configuration
  #
  # This file imports domain-specific system defaults and configures
  # core system meta settings.
  #
  # Domain-specific settings are organized into separate files:
  # - dock.nix: Dock, Spaces, Mission Control
  # - finder.nix: Finder preferences
  # - input.nix: Keyboard, trackpad, NSGlobalDomain input settings
  # - updates.nix: Software Update settings
  ##########################################################################

  imports = [
    ./dock.nix
    ./finder.nix
    ./input.nix
    ./updates.nix
  ];

  ##########################################################################
  # Authentication / Security
  ##########################################################################

  # Enable Touch ID for sudo authentication (where supported)
  security.pam.services.sudo_local.touchIdAuth = true;

  ##########################################################################
  # Core System Meta
  ##########################################################################
  system = {
    # Used by nix-darwin for backwards compatibility of module options.
    # Do not change without reading `darwin-rebuild changelog`.
    primaryUser = settings.username;
    stateVersion = 6;

    ########################################################################
    # Optional: Apply settings immediately after switch (commented)
    ########################################################################
    # activationScripts = {
    #   postUserActivation = {
    #     "${settings.username}" = {
    #       text = ''
    #         # Reload system/user settings so changes to defaults take effect.
    #         /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    #       '';
    #     };
    #   };
    # };
  };
}
