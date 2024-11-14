{
  pkgs,
  ...
}:

{

  home.packages = with pkgs; [
    git-machete
  ];

  programs.git.aliases = {
    m = "!${pkgs.git-machete}/bin/git machete";
  }

}
