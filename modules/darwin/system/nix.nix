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
      # macOS stamps `com.apple.macl` on an .app bundle once it is granted a TCC
      # permission. That xattr makes the bundle un-chmod-able, so when the path
      # later becomes garbage `nix-collect-garbage` aborts the ENTIRE run on it
      # (deleting one path, freeing nothing) and every subsequent sweep dies the
      # same way. Retry, stripping the macl off whichever path blocked us — only
      # ever a dead path, so no live app loses its TCC grants.
      for _ in 1 2 3 4 5; do
        gc_out=$(/nix/var/nix/profiles/default/bin/nix-collect-garbage --delete-older-than 30d 2>&1)
        gc_rc=$?
        printf '%s\n' "$gc_out"
        [ $gc_rc -eq 0 ] && break
        gc_blocked=$(printf '%s\n' "$gc_out" | sed -n 's/.*fchmodat "\(.*\)".*/\1/p' | head -1)
        [ -n "$gc_blocked" ] || break
        echo "nix-gc: clearing com.apple.macl from $gc_blocked"
        /usr/bin/xattr -d com.apple.macl "$gc_blocked" 2>/dev/null || break
      done
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
