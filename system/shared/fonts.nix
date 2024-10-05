{
  pkgs,
  ...
}:

{

  fonts.packages = with pkgs; [
    # https://www.nerdfonts.com/font-downloads
    (nerdfonts.override {
      fonts = [
        "FiraCode"
        "JetBrainsMono"
      ];
    })
  ];

}
