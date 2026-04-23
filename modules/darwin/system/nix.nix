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
}
