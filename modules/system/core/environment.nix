{ pkgs
, settings
, ...
}:
{

  # List packages installed in system profile (All users)
  environment = {
    variables = settings.variables;
  };

}
