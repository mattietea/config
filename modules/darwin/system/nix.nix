{ pkgs, ... }:
{
  # Determinate Nix owns /etc/nix/nix.conf; override via nix.custom.conf.
  environment.etc."nix/nix.custom.conf".text = ''
    # Determinate defaults trusted-users to just `root`, which leaves admin
    # users untrusted. devenv then can't pass the `system` setting to the
    # daemon and fails with "Failed to get drvPath from shell derivation".
    trusted-users = root @admin
    eval-cores = 0
    extra-substituters = https://devenv.cachix.org https://nix-community.cachix.org https://cache.numtide.com https://claude-code-nix.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g= claude-code-nix.cachix.org-1:VzA1HW3CkJnuSQaPE1t7OfSaleacUnO19VrZ3hJFH+0=
  '';

  # Root-level GC: prunes system/root profile generations and collects garbage,
  # then hardlink-dedupes the store (typically 25-35% smaller). User-level
  # (home-manager) generations are NOT reachable from a root GC — those are
  # expired by services.home-manager.autoExpire in lib/mkHost.nix.
  # launchd's `command` is exec-wrapped, so compound commands need a script.
  launchd.daemons.nix-gc = {
    command = "${pkgs.writeShellScript "nix-gc" ''
      /nix/var/nix/profiles/default/bin/nix-collect-garbage --delete-older-than 30d
      /nix/var/nix/profiles/default/bin/nix store optimise
    ''}";
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
