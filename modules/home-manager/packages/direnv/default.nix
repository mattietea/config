_: {
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    silent = true;
    config.global.warn_timeout = "30s";
  };
}
