{
  pkgs,
  ...
}:

{

  home.packages = with pkgs; [
    renameutils
  ];

  programs.zsh.shellAliases = {
    rename = "${pkgs.renameutils}/bin/qmv -f do";
  };

}
