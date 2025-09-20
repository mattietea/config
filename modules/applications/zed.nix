{
  pkgs,
  ...
}:

{

  home.packages = with pkgs; [
    nixfmt
    nixd
  ];

  # https://home-manager-options.extranix.com/?query=programs.zed&release=master

  programs.zed-editor = {
    enable = true;

    extensions = [
      "nix"
    ];

    userSettings = {

      languages = {
        Nix = {
          language_servers = [
            "nixd"
          ];
        };
      };

      lsp = {
        nixd = {
          binary = {
            path = "${pkgs.nixd}/bin/nixd";
          };
          settings = {
            diagnostic = {
              suppress = [ "sema-extra-with" ];
            };
          };
        };
      };
    };

  };

  # programs.zed-editor.userKeymaps = [
  #   {
  #     context = "Workspace";
  #     bindings = {
  #       ctrl-shift-t = "workspace::NewTerminal";
  #     };
  #   };
  # ]

  # programs.zed-editor.userKeymaps = [
  #   {
  #     context = "Workspace";
  #     bindings = {
  #       ctrl-shift-t = "workspace::NewTerminal";
  #     };
  #   };
  # ]

}
