{
  ##########################################################################
  # Nix daemon settings (Determinate Nix override)
  #
  # Determinate Nix owns /etc/nix/nix.conf and includes nix.custom.conf
  # for user overrides. We manage that file here.
  ##########################################################################

  environment.etc."nix/nix.custom.conf".text = ''
    eval-cores = 0
    extra-substituters = https://devenv.cachix.org https://nix-community.cachix.org https://opencode.cachix.org https://claude-code-nix.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= opencode.cachix.org-1:LdhuFTs/xrlYuchvsF+cOBCgCKEJIcesw9ef06GPlXU= claude-code-nix.cachix.org-1:VzA1HW3CkJnuSQaPE1t7OfSaleacUnO19VrZ3hJFH+0=
  '';
}
