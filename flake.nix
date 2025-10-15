{
  description = "mattietea's system configuration file";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs =
    {
      self,
      darwin,
      nixpkgs,
      home-manager,
      mac-app-util,
      ...
    }@inputs:
    let
      # Settings
      settings = {
        # Used by git, might try and think of a better way
        username = "mattietea";
        email = "mattcthomas@me.com";
        variables = {
          EDITOR = "zed --wait";
          VISUAL = "zed --wait";
        };
      };
    in
    {
      darwinConfigurations = {
        work = import ./hosts/work { inherit inputs settings; };
        personal = import ./hosts/personal { inherit inputs settings; };

        # Compatibility aliases for hostname-based switching
        Matts-Work-MacBook-Pro = import ./hosts/work { inherit inputs settings; };
        Matts-Personal-Macbook = import ./hosts/personal { inherit inputs settings; };
      };

      # Formatter configuration
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
      formatter.x86_64-darwin = nixpkgs.legacyPackages.x86_64-darwin.nixfmt-rfc-style;

    };
}
