{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.pkgs.television;
in
{
  options.pkgs.television = {
    enable = lib.mkEnableOption "television";

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {
        tick_rate = 50;
        ui = {
          use_nerd_font_icons = true;
          show_preview_panel = true;
        };
      };
      description = "television settings";
    };

    channels = lib.mkOption {
      type = lib.types.attrs;
      default = {
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
      description = "television channels configuration";
    };

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Zsh integration for television";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.fd.enable = true;
    programs.ripgrep.enable = true;

    programs.television = {
      enable = true;
      enableZshIntegration = cfg.enableZshIntegration;
      settings = cfg.settings;
      channels = cfg.channels;
    };
  };
}
