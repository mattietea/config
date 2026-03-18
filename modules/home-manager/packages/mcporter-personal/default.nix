_:
let
  baseServers = import ../mcporter/servers-base.nix;
in
{
  home.file.".mcporter/mcporter.json".text = builtins.toJSON {
    "$schema" = "https://raw.githubusercontent.com/steipete/mcporter/main/mcporter.schema.json";
    mcpServers = baseServers;
  };
}
