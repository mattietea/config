{
  # Determinate Nix owns /etc/nix/nix.conf; override via nix.custom.conf.
  environment.etc."nix/nix.custom.conf".text = ''
    eval-cores = 0
    extra-substituters = https://devenv.cachix.org https://nix-community.cachix.org https://cache.numtide.com
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=
  '';

  launchd.daemons.nix-gc = {
    command = "/nix/var/nix/profiles/default/bin/nix-collect-garbage --delete-older-than 30d";
    serviceConfig = {
      StartCalendarInterval = [
        {
          Weekday = 0;
          Hour = 3;
          Minute = 0;
        }
      ];
      StandardOutPath = "/var/log/nix-gc.log";
      StandardErrorPath = "/var/log/nix-gc.log";
    };
  };

  system.activationScripts.postActivation.text = ''
    nix-env --profile /nix/var/nix/profiles/system --delete-generations +5 2>/dev/null || true
  '';
}
