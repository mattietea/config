{
  pkgs,
  settings,
  ...
}:
{

  # TODO: Is this needed?
  programs = {
    zsh.enable = true;

    # Disable zsh completion
    # As we call it ourselves later in the process
    zsh.enableCompletion = false;
  };

  # List packages installed in system profile (All users)
  environment = {

    shells = [
      pkgs.nushell
      pkgs.zsh
      pkgs.bash
    ];

    loginShell = pkgs.zsh;

    variables = settings.variables;
  };

}
