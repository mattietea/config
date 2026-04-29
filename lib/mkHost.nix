{
  inputs,
  settings,
  hostname,
  system ? "aarch64-darwin",
  applications ? [ ],
  packages ? [ ],
  ai ? [ ],
  darwinModules ? [ ],
}:
let
  applicationNames = map builtins.baseNameOf applications;
in
inputs.darwin.lib.darwinSystem {
  specialArgs = {
    inherit inputs settings applicationNames;
  };
  modules = [
    {
      nixpkgs = {
        hostPlatform = system;
        overlays = [ ];
        config = {
          allowUnfree = true;
          allowInsecurePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) [ "google-chrome" ];
        };
      };
      nix.enable = false;
      documentation.enable = false;
      users.users.${settings.username} = {
        name = settings.username;
        home = "/Users/${settings.username}";
      };
    }
    ../modules/darwin/system
    inputs.agenix.darwinModules.default
    {
      age = {
        identityPaths = [ "/Users/${settings.username}/.ssh/id_ed25519" ];
        secrets = {
          context7-api-key = {
            file = ../secrets/context7-api-key.age;
            owner = settings.username;
          };
          exa-api-key = {
            file = ../secrets/exa-api-key.age;
            owner = settings.username;
          };
        };
      };
    }
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = null;
        backupCommand = "/bin/rm -f";
        extraSpecialArgs = { inherit settings inputs applicationNames; };
        sharedModules = applications ++ packages ++ ai;
        users.${settings.username} = {
          targets.darwin.copyApps.enable = true;
          manual = {
            json.enable = false;
            html.enable = false;
            manpages.enable = false;
          };
          home = {
            inherit (settings) username;
            homeDirectory = "/Users/${settings.username}";
            sessionVariables = settings.variables;
            stateVersion = "25.11";
          };
        };
      };
    }
    { networking.hostName = hostname; }
  ]
  ++ darwinModules;
}
