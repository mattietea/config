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
      git-log = {
        metadata = {
          description = "A channel to select from git log entries";
          name = "git-log";
          requirements = [
            "git"
          ];
        };
        preview = {
          command = "git show -p --stat --pretty=fuller --color=always '{0}'";
        };
        source = {
          command = "git log --oneline --date=short --pretty=\"format:%h %s %an %cd\" \"$@\"";
          output = "{split: :0}";
        };
      };
      files = {
        metadata = {
          description = "A channel to select files and directories";
          name = "file";
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
            "${pkgs.fd}/bin/fd -t f"
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
      text = {
        metadata = {
          description = "A channel to find and select text from files";
          name = "text";
          requirements = [
            "rg"
            "bat"
          ];
        };
        ui = {
          preview_panel = {
            header = "{split:\\::..2}";
          };
        };
        preview = {
          command = "${pkgs.bat}/bin/bat -n --color=always '{split:\\::0}'";
          offset = "{split:\\::1}";
          env = {
            BAT_THEME = "ansi";
          };
        };
        source = {
          command = "${pkgs.ripgrep}/bin/rg . --no-heading --line-number";
          display = "[{split:\\::..2}]\t{split:\\::2..}";
          output = "{split:\\::..2}";
        };
      };

    };
  };

}
