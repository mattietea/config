{ inputs }:
let
  inherit (import ../lib/hosts.nix)
    app
    trivialPkg
    commonApps
    commonPackages
    commonVariables
    ;

  settings = {
    username = "mattietea";
    name = "Matt Thomas";
    github = "mattietea";
    email = "mattcthomas@me.com";
    variables = commonVariables;
  };

  mkHost = import ../lib/mkHost.nix;
in
mkHost {
  inherit inputs settings;
  hostname = "Matts-Personal-Macbook-Air";

  applications =
    commonApps
    ++ map app [
      "brave"
      "discord"
      "google-chrome"
      "raycast"
      "safari"
      "spotify"
    ];

  packages = commonPackages ++ map trivialPkg [ "wacli" ];

  ai = [
    ../modules/ai
    ../modules/ai/personal.nix
  ];
}
