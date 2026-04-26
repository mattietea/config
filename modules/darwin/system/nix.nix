{
  ##########################################################################
  # Nix daemon settings (Determinate Nix override)
  #
  # Determinate Nix owns /etc/nix/nix.conf and includes nix.custom.conf
  # for user overrides. We manage that file here.
  ##########################################################################

  environment.etc."nix/nix.custom.conf".text = ''
    eval-cores = 0
    extra-substituters = https://devenv.cachix.org https://nix-community.cachix.org https://cache.numtide.com
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=
  '';

  ##########################################################################
  # Automatic garbage collection
  #
  # Runs weekly, deletes store paths not referenced in the last 30 days.
  ##########################################################################

  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 3;
      Minute = 0;
    };
    options = "--delete-older-than 30d";
  };

  ##########################################################################
  # Generation cleanup
  #
  # Keep only the last 5 system generations on each switch.
  ##########################################################################

  system.activationScripts.postActivation.text = ''
    nix-env --profile /nix/var/nix/profiles/system --delete-generations +5 2>/dev/null || true
  '';
}
