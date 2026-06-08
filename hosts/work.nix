{ inputs }:
let
  inherit (import ../lib/hosts.nix)
    pkg
    commonApps
    commonPackages
    commonVariables
    ;

  settings = {
    username = "matthewthomas";
    name = "Matthew Thomas";
    github = "mattietea-harvey";
    email = "matthew.thomas@harvey.ai";
    variables = commonVariables;
  };

  mkHost = import ../lib/mkHost.nix;
in
mkHost {
  inherit inputs settings;
  hostname = "Castula-KQPN";

  applications = commonApps;

  packages =
    commonPackages
    ++ map pkg [
      "gws"
      "pup"
      "sentry"
      "worktrunk-work"
    ];

  ai = [
    ../modules/ai
    ../modules/ai/work.nix
  ];

  darwinModules = [
    {
      age.secrets.anthropic-api-key = {
        file = ../secrets/anthropic-api-key.age;
        owner = settings.username;
      };
    }
  ];
}
