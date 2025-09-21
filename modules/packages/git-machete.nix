{
  pkgs,
  ...
}:

{

  home.packages = with pkgs; [
    git-machete
  ];

  programs.git.aliases = {
    m = "machete";
  };

}
