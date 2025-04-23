/**
  Builds a Darwin (macOS) system configuration using nix-darwin and home-manager.
  This function sets up the core system and integrates home-manager for user-specific configurations.

  # Examples

  ```nix
  buildDarwin {
  settings = {
      username = "johndoe";
      name = "John Doe";
      email = "john@example.com";
  };
  inputs = inputs;
  modules = {
      system = [ ./system/darwin.nix ./host/core.nix ];
      user = [ ./modules/programs/git.nix ./modules/programs/zsh.nix ];
  };
  }
  ```
*/
{
  # The username of the primary user of the system.
  user
, # An attribute set containing user-specific settings like name, email, and variables.
  settings
, # The flake inputs, providing access to nixpkgs, home-manager, and other dependencies.
  inputs
, # An attribute set containing lists of system-wide and user-specific NixOS modules to be included in the configuration.
  modules
,
}:

inputs.darwin.lib.darwinSystem {
  # Pass special arguments to all modules
  specialArgs = {
    inherit settings inputs user;
  };

  system = "aarch64-darwin";

  # Combine system-wide modules with home-manager
  modules = modules.system ++ [

    inputs.home-manager.darwinModules.home-manager
    {
      home-manager = {
        # Pass additional special arguments to home-manager modules
        extraSpecialArgs = {
          inherit settings inputs;
        };

        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";

        # Configure home-manager for the specified user
        users.${user} = {
          # Set the state version for this user's home-manager configuration
          home.stateVersion = "24.11";
        };

        # Include shared user modules
        sharedModules = modules.user;
      };
    }
  ];
}
