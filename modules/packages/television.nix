{
  pkgs,
  ...
}:

{
  # https://home-manager-options.extranix.com/?query=programs.television&release=master

  programs.fd.enable = true;
  programs.ripgrep.enable = true;

  programs.television = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      tick_rate = 50;
      ui = {
        use_nerd_font_icons = true;
        # ui_scale = 120;
        show_preview_panel = true;
      };
    };

    channels = {
      files = {
        metadata = {
          description = "A channel to select files and directories";
          name = "files";
          requirements = [
            "fd"
            "bat"
          ];
        };
        preview = {
          command = "${pkgs.bat}/bin/bat -n --color=always '{}'";
        };
        source = {
          command = [
            # "${pkgs.fd}/bin/fd -t f"
            "${pkgs.fd}/bin/fd -t f -H"
          ];
        };
      };
      folder = {
        metadata = {
          description = "A channel to select directories";
          name = "folder";
          requirements = [
            "fd"
          ];
        };
        preview = {
          command = "${pkgs.eza}/bin/eza -l --tree --color=always --icons {}";
        };
        source = {
          command = [
            "${pkgs.fd}/bin/fd -t d"
            "${pkgs.fd}/bin/fd -t d --hidden"
          ];
        };
      };
    };
  };

}
