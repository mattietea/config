let
  mattietea = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJeaF4HCFCT/8n56EAm9HOlCwcxBKSRA3kHU0wN6ZSpg";
  matthewthomas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH+w3Dh8VTus+ZdhZVGxAejiwvGTfQfjhp5ZHnR6UoUj";
  all = [
    mattietea
    matthewthomas
  ];
in
{
  "context7-api-key.age".publicKeys = all;
  "exa-api-key.age".publicKeys = all;
}
